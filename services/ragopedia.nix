{ config, lib, pkgs, ... }:
let ragopediaPort = "2813";
in
{
  services.nginx.virtualHosts."ragopedia.tlkg.org.tr" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:${ragopediaPort}";
  };
}
