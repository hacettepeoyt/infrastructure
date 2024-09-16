HEAVY_FLAKES := github:div72/mailpot

.PHONY: help
help:
	@echo "make deploy                     ---> Sends the configuration to the server."
	@echo "make pre-build                  ---> Builds heavy flake inputs and copies them to the server."
	@echo "make update-input INPUT=<input> ---> Updates a specific input and commits it."

.PHONY: deploy
deploy:
	ssh -tt -A $(USER)@ozguryazilimhacettepe.com "sudo chmod -R g+w /etc/nixos"
	git pull server main
	git push server main
	@# Check if current branch is rebased to main. This can cause a rollback of changes otherwise.
	@git branch --contains $$(git log --format=format:%H -1 main) | grep -q $$(git rev-parse --abbrev-ref HEAD) \
	|| (echo "ERROR: Branch is not rebased to master, please rebase." && exit 1)
	git push --force-with-lease server
	@# Agent forwarding allows using sudo using the local agent.
	ssh -tt -A $(USER)@ozguryazilimhacettepe.com "cd /etc/nixos && git checkout $$(git rev-parse --abbrev-ref HEAD) && sudo nixos-rebuild switch"

# Only use this if you have the same arch as the server!
.PHONY: pre-build
pre-build:
	nix-copy-closure --to --gzip --use-substitutes $(USER)@ozguryazilimhacettepe.com $$(nix build --refresh --quiet --no-link --print-out-paths $(HEAVY_FLAKES))

.PHONY: update-input
update-input:
	@nix eval --file flake.nix --apply "inputs: inputs ? $(INPUT)" inputs 2>/dev/null | grep -q true \
	|| (echo "ERROR: Missing input: $(INPUT)" && exit 1)
	nix flake lock --update-input $(INPUT) --commit-lock-file
