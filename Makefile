HEAVY_FLAKES := .\#inputs.mailpot.outputs.packages.aarch64-linux.default .\#inputs.nixpkgs.outputs.legacyPackages.aarch64-linux.olm .\#inputs.conduwuit.outputs.packages.aarch64-linux.static-aarch64-linux-musl

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
