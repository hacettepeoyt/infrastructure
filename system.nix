{ config, libs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix

    ./dns.nix
    services/headscale.nix
    services/hu-announcement-bot.nix
    services/hu-cafeteria-bot.nix
    services/mail.nix
    services/matrix.nix
    services/minecraft.nix
    services/monit.nix
    services/murmur.nix
    services/oyt-website.nix
    services/tlkg-website.nix
  ];

  system.stateVersion = "23.05";

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # DO NOT TOUCH THIS. Otherwise after a while /boot will fill up and all hell will break loose.
  boot.loader.grub.configurationLimit = 5;
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 10d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@wheel" ];

  networking.hostName = "vflower";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 10022 25565 ];
  networking.firewall.allowedUDPPorts = [ 19132 ];

  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  programs.mosh.enable = true;
  programs.zsh.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.GatewayPorts = "yes";
  services.fail2ban.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "sysadmin@lists.tlkg.org.tr";
  };

  services.nginx = {
    enable = true;

    virtualHosts."wiki.ozguryazilimhacettepe.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/srv/http/wiki.ozguryazilimhacettepe.com";
    };
  };

  age.secrets = builtins.listToAttrs (map (user: { name = "passwd-${user}"; value = { file = ./secrets/passwd/${user}.age; }; }) (builtins.filter (user: config.users.users."${user}".isNormalUser) (builtins.attrNames config.users.users))) // {
    oyt-website = {
      file = secrets/services/oyt-website.age;
      owner = "oyt-website";
    };
  };
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVb2l/23ykDnfhO5VrkCQaycfF9oCo1Jig/JeG86w//'' ];
  users.users = {
    div72 = {
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets.passwd-div72.path;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      packages = [ ]; # packages managed by home-manager
      openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVb2l/23ykDnfhO5VrkCQaycfF9oCo1Jig/JeG86w//'' ];
    };

    ikolomiko = {
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets.passwd-ikolomiko.path;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      packages = [ pkgs.git pkgs.screen pkgs.vim pkgs.eza pkgs.htop pkgs.ncdu ];
      openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6fYwAAYEKncSRGjh+xVE8toRB4ztmBFDFX2wShZAPw'' ];
    };

    f1nch = {
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets.passwd-f1nch.path;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      packages = [
        pkgs.git pkgs.vim pkgs.nix-prefetch

        (pkgs.writeShellScriptBin "bump-cafeteria-bot" ''
          cd /etc/nixos

          set -e

          if [ ! -z "$(git status --porcelain)" ]; then
            echo "Somebody forgot to commit the changes! Exiting."
            exit 1
          fi

          if [ -z "$SSH_AUTH_SOCK" ]; then
            echo "You need to forward your SSH agent. (ssh -A ...)"
            exit 1
          fi

          sudo chgrp -R wheel /etc/nixos
          sudo chmod -R g+w /etc/nixos

          new_hash=$(nix-prefetch fetchFromGitHub --owner hacettepeoyt --repo hu-cafeteria-bot --rev "v$1")
          sed -i -r -e 's|hash = "sha256-[a-zA-Z0-9/=]+";|hash = "'"$new_hash"'";|g' /etc/nixos/services/hu-cafeteria-bot.nix
          sed -i -r -e 's|version = "[0-9.-]+";|version = "'"$1"'";|g' /etc/nixos/services/hu-cafeteria-bot.nix

          sudo nixos-rebuild switch
          git add /etc/nixos/services/hu-cafeteria-bot.nix
          git commit -m "services: bump hu-cafeteria-bot to $1"
          git push
        '')

        (pkgs.writeShellScriptBin "bump-announcement-bot" ''
          cd /etc/nixos

          set -e

          if [ ! -z "$(git status --porcelain)" ]; then
            echo "Somebody forgot to commit the changes! Exiting."
            exit 1
          fi

          if [ -z "$SSH_AUTH_SOCK" ]; then
            echo "You need to forward your SSH agent. (ssh -A ...)"
            exit 1
          fi

          sudo chgrp -R wheel /etc/nixos
          sudo chmod -R g+w /etc/nixos

          new_hash=$(nix-prefetch fetchFromGitHub --owner hacettepeoyt --repo hu-announcement-bot --rev "v$1")
          sed -i -r -e 's|hash = "sha256-[a-zA-Z0-9/=]+";|hash = "'"$new_hash"'";|g' /etc/nixos/services/hu-announcement-bot.nix
          sed -i -r -e 's|version = "[0-9.-]+";|version = "'"$1"'";|g' /etc/nixos/services/hu-announcement-bot.nix

          sudo nixos-rebuild switch
          git add /etc/nixos/services/hu-announcement-bot.nix
          git commit -m "services: bump hu-announcement-bot to $1"
          git push
        '')
      ];
      openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKjtQ/SbNBCTSWimPetOw4veFxXANwPNdprjFiEQa2O'' ];
    };

    automata = {
      isSystemUser = true;
      group = "automata";
      openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAee49tO2W172hMqjiUxIYP7IGNVhwWQt1N8kk/w13WA'' ];
    };
  };

  users.groups.automata = { };

  environment.systemPackages = [ pkgs.gnuplot ];

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "tailscale0" ];
    extraCommands = ''
      iptables -t nat -A POSTROUTING -d 100.64.0.1 -p tcp -m tcp --dport 10022 -j MASQUERADE
    '';
    /*forwardPorts = [
      {
        destination = "100.64.0.1:22";
        proto = "tcp";
        sourcePort = 10022;
      }
    ];*/
  };
}
