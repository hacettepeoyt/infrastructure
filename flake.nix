{
  description = "System flake";

  inputs = {
    agenix.url = "github:ryantm/agenix/main";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hu-cafeteria-bot.url = "github:hacettepeoyt/hu-cafeteria-bot";
  };

  outputs = { self, agenix, hu-cafeteria-bot, nixpkgs }: {
    nixosConfigurations."hacettepeoyt-vflower" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          agenix.nixosModules.default
          hu-cafeteria-bot.nixosModules
          ./system.nix
        ];
    };
  };
}
