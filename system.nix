{ config, libs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix

    ./dns.nix
    services/chat.nix
    services/faceless.nix
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
    services/bitirme-website.nix
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
  # FIXME: Temporary fix for issue https://github.com/NixOS/nixpkgs/issues/386392.
  # Courtesy of @psub - https://github.com/pSub/configs/blob/64a784b4b88d3579475294cb3e8797a7de68dddc/nixos/server/overlays/pam_ssh_agent_auth.nix
  nixpkgs.overlays = [
    (final:  prev :
    {
       pam_ssh_agent_auth = prev.pam_ssh_agent_auth.overrideAttrs (old: {
        fixupPhase = ''
          patchelf --add-needed ${prev.libgcc}/lib/libgcc_s.so.1 $out/libexec/pam_ssh_agent_auth.so
        '';
      });
    })
  ];

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
  # The users.nix file contain the human users. As opposed to the alien users, of course.
  users.users = (import ./users.nix { inherit config pkgs; }) // {
    root.openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVb2l/23ykDnfhO5VrkCQaycfF9oCo1Jig/JeG86w//'' ];

    automata = {
      isSystemUser = true;
      group = "automata";
      openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAee49tO2W172hMqjiUxIYP7IGNVhwWQt1N8kk/w13WA'' ];
    };
  };

  users.groups.automata = { };

  environment.systemPackages = [
    pkgs.git
    pkgs.gnuplot
    pkgs.vim
  ];

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
