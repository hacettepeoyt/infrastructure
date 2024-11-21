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
}
