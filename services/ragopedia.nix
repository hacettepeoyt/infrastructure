{ config, lib, pkgs, ... }:
let ragopediaPort = "2813";
    ragopediaApiPort = "2814";
in
{
  services.nginx.virtualHosts."ragopedia.tlkg.org.tr" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:${ragopediaPort}";
  };
  services.nginx.virtualHosts."ragopedia-api.tlkg.org.tr" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:${ragopediaApiPort}";
  };
}
