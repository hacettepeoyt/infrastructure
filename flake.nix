{
  description = "System flake";

  inputs = {
    agenix.url = "github:ryantm/agenix/main";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, agenix, nixpkgs }: {
    nixosConfigurations."hacettepeoyt-vflower" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          agenix.nixosModules.default
          ./system.nix
        ];
    };
  };
}
