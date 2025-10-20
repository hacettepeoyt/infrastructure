{
  description = "System flake";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mailpot = {
      url = "github:div72/mailpot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
          {
            nixpkgs.overlays = [
              (final: prev: {
                mailpot = mailpot.packages.aarch64-linux.mailpot;
                # FIXME: continuwuity rc7 and rc8 has bug with joining policy server protected rooms.
                # Can be removed after release.
                # See https://forgejo.ellis.link/continuwuation/continuwuity/issues/1060.
                matrix-continuwuity = nixpkgsOld.legacyPackages.aarch64-linux.matrix-continuwuity;
              })
            ];
          }
        ];
    };
  };
}
