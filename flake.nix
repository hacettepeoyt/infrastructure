{
  description = "System flake";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mailpot = {
      url = "github:div72/mailpot";
      inputs.nixpkgs.follows = "nixpkgsOld";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgsOld.url = "github:NixOS/nixpkgs/8cd5ce828d5d1d16feff37340171a98fc3bf6526";
    hu-announcement-bot = {
      url = "github:hacettepeoyt/hu-announcement-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hu-cafeteria-bot = {
      url = "github:hacettepeoyt/hu-cafeteria-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, agenix, hu-announcement-bot, hu-cafeteria-bot, mailpot, nixpkgs, nixpkgsOld }: {
    inherit inputs;

    nixosConfigurations."vflower" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          agenix.nixosModules.default
          hu-announcement-bot.nixosModules
          hu-cafeteria-bot.nixosModules
          ./system.nix
        ];
    };
  };
}
