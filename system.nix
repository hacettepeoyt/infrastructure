{ config, libs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    services/hu-announcement-bot.nix
    services/hu-cafeteria-bot.nix
    services/jitsi.nix
    services/mail.nix
    services/oyt-website.nix
  ];

  system.stateVersion = "23.05";

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # DO NOT TOUCH THIS. Otherwise after a while /boot will fill up and all hell will break loose.
  boot.loader.grub.configurationLimit = 2;
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 10d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "hacettepeoyt-vflower";
  networking.enableIPv6 = true;
  networking.useDHCP = true;
  networking.domain = "";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 25565 ];
  networking.firewall.allowedUDPPorts = [ 19132 ];

  programs.mosh.enable = true;
  programs.zsh.enable = true;

  services.openssh.enable = true;
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

    virtualHosts."huannouncementbot.ozguryazilimhacettepe.com" = {
      forceSSL = true;
      enableACME = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:51966";
        };
      };
    };

    virtualHosts."status.ozguryazilimhacettepe.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/lib/statie";
    };
  };

  systemd.services.minecraft-server = {
    enable = false;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    startLimitBurst = 3;
    startLimitIntervalSec = 60;

    serviceConfig = {
      ExecStart = "/etc/profiles/per-user/minecraft/bin/minecraft-server";

      Restart = "always";
      WorkingDirectory = "/srv/minecraft";
      User = "minecraft";
      Group = "minecraft";
      Type = "simple";

      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0007";
    };
  };

  age.secrets = builtins.listToAttrs (map (user: { name = "passwd-${user}"; value = { file = ./secrets/passwd/${user}.age; }; }) (builtins.filter (user: config.users.users."${user}".isNormalUser) (builtins.attrNames config.users.users))) // {
    hu-cafeteria-bot = {
      file = secrets/services/hu-cafeteria-bot.age;
      owner = "hu-cafeteria-bot";
    };
    hu-announcement-bot = {
      file = secrets/services/hu-announcement-bot.age;
      owner = "hu-announcement-bot";
    };
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

    LinoxGH = {
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets.passwd-LinoxGH.path;
      extraGroups = [ "minecraft" ];
      openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqibdeU7gLufY1Hs2AG9V1KjbhSDTM1C1Q6zRrB1h5D'' ];
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

    minecraft = {
      isSystemUser = true;
      home = "/srv/minecraft";
      createHome = true;
      homeMode = "770";
      group = "minecraft";
      packages = [ pkgs.papermc ];
    };

    statie = {
      isSystemUser = true;
      home = "/var/lib/statie";
      createHome = true;
      homeMode = "755";
      group = "statie";
      packages = [ pkgs.gnuplot ];
    };

  };

  users.groups.minecraft = { };
  users.groups.statie = { };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/15 * * * *      statie    /var/lib/statie/hacettepeoyt.sh > /var/lib/statie/index.html 2> /var/lib/statie/error.log"
    ];
  };

  environment.systemPackages = [ pkgs.gnuplot ];

  security.sudo.extraRules = [
    {
      groups = [ "minecraft" ];
      commands = [
        "/run/current-system/sw/bin/systemctl start minecraft-server"
        "/run/current-system/sw/bin/systemctl stop minecraft-server"
        "/run/current-system/sw/bin/systemctl restart minecraft-server"
        "/run/current-system/sw/bin/journalctl -eu minecraft-server"
      ];
    }
  ];

  nixpkgs.overlays = [
    ( final: prev: {
        # FIXME: Drop this when 9.8 hits nixos-unstable (https://nixpk.gs/pr-tracker.html?pr=323753)
        openssh = prev.openssh.overrideAttrs (finalAttrs: previousAttrs: rec {
          version = "9.8p1";
          src = prev.fetchurl {
            url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
            hash = "sha256-3YvQAqN5tdSZ37BQ3R+pr4Ap6ARh9LtsUjxJlz9aOfM=";
          };
        });
        papermc = prev.papermc.overrideAttrs (finalAttrs: previousAttrs: {
          version = "1.20.2.234";

          src =
            let
              mcVersion = prev.lib.versions.pad 3 finalAttrs.version;
              buildNum = builtins.elemAt (prev.lib.splitVersion finalAttrs.version) 3;
            in
            prev.fetchurl {
              url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
              hash = "sha256-fR7Dq09iFGVXodQjrS7Hg4NcrKPJbNg0hexU520JC6c=";
            };
        });
    })
  ];
}
