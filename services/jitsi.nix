{ ... }:

{
  /*services.nginx.virtualHosts."jitsi.ozguryazilimhacettepe.com" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:8001";
      };
      "/xmpp-websocket" = {
        proxyPass = "http://localhost:8001/xmpp-websocket";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          tcp_nodelay on;
'';
      };
      "/colibri-ws" = {
        proxyPass = "http://localhost:8001/colibri-ws";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          tcp_nodelay on;
'';
      };
    };
  };*/
/*
  services.jitsi-meet = {
    enable = true;
    hostName = "jitsi.ozguryazilimhacettepe.com";
    # chromedriver is not available for aarch64-linux.
    # jibri.enable = true;
  };
*/

  /*virtualisation.oci-containers = {
    backend = "podman";

    containers.jibri = {
      image = "jitsi/jibri:stable";
      extraOptions = [
        "--shm-size=2G"
      ];
      environment = {
        JIBRI_RECORDER_PASSWORD = "a";
      };
    };
  };*/
}
