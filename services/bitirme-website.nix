{ pkgs, ... }:
{
  services.nginx.virtualHosts."bitirme.tlkg.org.tr" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      root = "/srv/http/bitirme.tlkg.org.tr/";
    };
  };
}
