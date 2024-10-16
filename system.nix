{ config, libs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ./dns.nix
    services/hu-announcement-bot.nix
    services/hu-cafeteria-bot.nix
    services/jitsi.nix
    services/mail.nix
    services/minecraft.nix
    services/oyt-website.nix
    website/website.nix
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
  networking.domain = "";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 25565 ];
  networking.firewall.allowedUDPPorts = [ 19132 ];

  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  programs.mosh.enable = true;
  programs.zsh.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.GatewayPorts = "yes";
  services.fail2ban.enable = true;

  virtualisation.docker.enable = true;

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "hacettepeoyt_letsencrypt@div72.xyz";
  };

  services.nginx = {
    enable = true;

    virtualHosts."wiki.ozguryazilimhacettepe.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/srv/http/wiki.ozguryazilimhacettepe.com";
    };

    virtualHosts."intin.com.tr" = {
      forceSSL = true;
      enableACME = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:8282";
        };
      };
    };

    virtualHosts."api.intin.com.tr" = {
      forceSSL = true;
      enableACME = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:8383";
        };
      };
    };

    virtualHosts."status.ozguryazilimhacettepe.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/lib/statie";
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
      extraGroups = [ "wheel" "docker" ];
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

    statie = {
      isSystemUser = true;
      home = "/var/lib/statie";
      createHome = true;
      homeMode = "755";
      group = "statie";
      packages = [ pkgs.gnuplot ];
    };

    automata = {
      isSystemUser = true;
      group = "automata";
      openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAee49tO2W172hMqjiUxIYP7IGNVhwWQt1N8kk/w13WA'' ];
    };
  };

  users.groups.statie = { };
  users.groups.automata = { };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/15 * * * *      statie    /var/lib/statie/hacettepeoyt.sh > /var/lib/statie/index.html 2> /var/lib/statie/error.log"
    ];
  };

  environment.systemPackages = [ pkgs.gnuplot ];
}
