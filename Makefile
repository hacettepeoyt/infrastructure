HEAVY_FLAKES := .\#inputs.mailpot.outputs.packages.aarch64-linux.default .\#inputs.nixpkgs.outputs.legacyPackages.aarch64-linux.olm .\#outputs.nixosConfigurations.vflower.config.services.matrix-conduit.package

.PHONY: help
help:
	@echo "make deploy                     ---> Sends the configuration to the server."
	@echo "make check                      ---> Checks the configuration."
	@echo "make pre-build                  ---> Builds heavy flake inputs and copies them to the server."
	@echo "make update-input INPUT=<input> ---> Updates a specific input and commits it."

.PHONY: check
check:
	nix eval --raw ".#nixosConfigurations.vflower.config.system.build.toplevel.drvPath"

.PHONY: deploy
deploy:
	git fetch server
	@# Check if current branch is rebased to main. This can cause a rollback of changes otherwise.
	@git branch --contains $$(git log --format=format:%H -1 server/main) | grep -q $$(git rev-parse --abbrev-ref HEAD) \
	|| (echo "ERROR: Branch is not rebased to master, please rebase." && exit 1)
	ssh -tt -A $(USER)@tlkg.org.tr "sudo chmod -R g+w /etc/nixos"
	git push --force-with-lease server
	@# Agent forwarding allows authenticating with sudo using the local agent.
	ssh -tt -A $(USER)@tlkg.org.tr "cd /etc/nixos && git checkout $$(git rev-parse --abbrev-ref HEAD) && sudo nixos-rebuild switch"

# Only use this if you have the same arch as the server!
.PHONY: pre-build
pre-build:
	nix-copy-closure --to --gzip --use-substitutes $(USER)@tlkg.org.tr $$(NIXPKGS_ALLOW_INSECURE=1 nix build --impure --refresh --quiet --no-link --print-out-paths --inputs-from . $(HEAVY_FLAKES))

.PHONY: update-input
update-input:
	@nix eval --file flake.nix --apply "inputs: inputs ? $(INPUT)" inputs 2>/dev/null | grep -q true \
	|| (echo "ERROR: Missing input: $(INPUT)" && exit 1)
	nix flake update $(INPUT) --commit-lock-file

.PHONY: backup
backup:
	@# FIXME: tar has some issues with printing to stdout with ssh -tt, so enforce root for now.
	ssh -tt -A root@tlkg.org.tr sudo lvcreate -pr -s -n lv_main_backup /dev/vg_main/lv_main
	ssh -tt -A root@tlkg.org.tr sudo lvchange -ay -Ky vg_main/lv_main_backup
	ssh -tt -A root@tlkg.org.tr sudo mount -o ro /dev/vg_main/lv_main_backup /mnt-backup
	ssh -A root@tlkg.org.tr "sudo tar --zstd -C /mnt-backup -vcf - etc/passwd etc/group etc/machine-id etc/ssh home srv var/lib" > backups/vflower-$$(date -u '+%Y-%m-%dT%H:%MZ%Z').tar.zstd
	ssh -tt -A root@tlkg.org.tr sudo umount /mnt-backup
	ssh -tt -A root@tlkg.org.tr sudo lvremove -y /dev/vg_main/lv_main_backup
