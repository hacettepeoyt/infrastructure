{ pkgs, ... }:
{
  services.nginx.virtualHosts."tlkg.org.tr" = {
    forceSSL = true;
    enableACME = true;

    # FIXME: Good lord, this is disgusting. Is there any other saner way to do this?
    locations."/" = {
      root = "/srv/http/tlkg.org.tr/";
      extraConfig = ''
        if ($http_user_agent ~* '(iPhone|iPod|android|blackberry)') {
            set $mobile 1;
        }

        if ($request_uri ~* '(mobile|css)') {
            set $mobile 0;
        }

        if ($mobile = 1) {
            return 301 /mobile$request_uri;
        }
      '';
    };
  };
}
