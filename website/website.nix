{ pkgs, ... }: {
  services.nginx.virtualHosts."tlkg.org.tr" = {
    forceSSL = true;
    enableACME = true;

    # TODO: Make this a proper package.
    locations."/".root = "${pkgs.writeTextDir "srv/http/index.html" (builtins.readFile ./index.html)}/srv/http/";
  };
}
