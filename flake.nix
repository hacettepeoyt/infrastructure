{
  description = "System flake";

  inputs = {
    agenix.url = "github:ryantm/agenix/main";
    mailpot.url = "github:div72/mailpot";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hu-announcement-bot.url = "github:hacettepeoyt/hu-announcement-bot";
    hu-cafeteria-bot.url = "github:hacettepeoyt/hu-cafeteria-bot";
  };

  outputs = { self, agenix, hu-announcement-bot, hu-cafeteria-bot, mailpot, nixpkgs }: {
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
              })
            ];
          }
        ];
    };
  };
}
