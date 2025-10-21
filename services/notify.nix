{ ... }: let
  internalPort = 9021;
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://notify.tlkg.org.tr";
      listen-http = ":${toString internalPort}";
    };
  };

  services.nginx.virtualHosts."notify.tlkg.org.tr" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://localhost:${toString internalPort}";
      recommendedProxySettings = true;
    };
  };
}
