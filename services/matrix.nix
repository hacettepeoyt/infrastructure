{ config, ... }: {
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = "tlkg.org.tr";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8448 ];

  services.nginx.virtualHosts."tlkg.org.tr" = {
    locations."/_matrix/" = {
      proxyPass = "http://localhost:${toString config.services.matrix-conduit.settings.global.port}";
      recommendedProxySettings = true;
    };

    extraConfig = ''
      listen 8448 ssl;
      listen [::]:8448 ssl;
      merge_slashes off;
    '';
  };

  # heisenbridge depends on mautrix which depends on olm by default. Olm has some timing attack concerns
  # that are not really scary since the homeserver is under our control.
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.heisenbridge = {
    enable = true;
    owner = "@div72:tlkg.org.tr";
    debug = true;
    homeserver = config.services.nginx.virtualHosts."tlkg.org.tr".locations."/_matrix/".proxyPass;
  };
}
