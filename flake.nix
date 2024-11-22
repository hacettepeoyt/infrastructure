{
  description = "System flake";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # FIXME: This can be replaced once a new version is on nixpkgs.
    conduwuit = {
      url = "github:girlbossceo/conduwuit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mailpot = {
      url = "github:div72/mailpot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hu-announcement-bot = {
      url = "github:hacettepeoyt/hu-announcement-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hu-cafeteria-bot = {
      url = "github:hacettepeoyt/hu-cafeteria-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, agenix, conduwuit, hu-announcement-bot, hu-cafeteria-bot, mailpot, nixpkgs }: {
    inherit inputs;

    nixosConfigurations."vflower" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          agenix.nixosModules.default
          hu-announcement-bot.nixosModules
          hu-cafeteria-bot.nixosModules
          ./system.nix
          {
            nixpkgs.overlays = [
              (final: prev: {
                conduwuit2 = conduwuit.packages.aarch64-linux.static-aarch64-linux-musl;
                mailpot = mailpot.packages.aarch64-linux.mailpot;
              })
            ];
          }
        ];
    };
  };
}
