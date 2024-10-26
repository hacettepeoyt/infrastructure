{ config, ... }: 
let
  domain = "headscale.tlkg.org.tr";
in
{
  services.tailscale.enable = true;

  services.headscale = {
    enable = true;
    port = 34321;
    settings.server_url = "https://${domain}";
  };

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };
}
