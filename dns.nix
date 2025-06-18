{ pkgs, ... }:
let
  vflower = { ipv4 = "49.12.221.115"; ipv6 = "2a01:4f8:c012:e483::1"; };

  mailServer = "mail.tlkg.org.tr";
  contactMail = "sysadmin@lists.tlkg.org.tr";

  dkimTxt = ''"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3htdYWpLHoEv8VY8q8iI9RA0JFGxOaRxjkqQHs/hhSfawsX5CSok1x/N3RHFyMcOzOwefnRAizAG3gGN5XX86E5Fwc31/CpLauVjDCeSM+qW/QzEOrZ4A6wklFLn0Hapa8kWGVrHno2VhYzd5JXeqs0z1ns5yRSl++SnFKKGYDeTDA6hz8rl8mDW68q8WAz/t" "SKjoF+vAnL2PFfCd2ygGvQoBKbZdR32P9F8bcZSx/14oHMi1SwTfZKDeUt+Ii+YsniBm355E5DQfEbsdCie5478gqWsTXTldqoEXV8vHAXWEayrIRapO4CWgYM7wISXwevuYpXJ39hQP2rjNOdUDwIDAQAB"'';
  dmarcPolicy = ''"v=DMARC1; p=quarantine; ruf=mailto:${contactMail}"'';
in
{
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.bind = {
    enable = true;
    zones = {
      "tlkg.org.tr" = {
        master = true;
        file = pkgs.writeText "tlkg.org.tr.zone" ''
          $ORIGIN tlkg.org.tr.
          $TTL    1h
          @            IN      SOA     ns0 ${builtins.replaceStrings [ "@" ] [ "." ] contactMail}. (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                       IN      NS      ns0

          @            IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}
                       IN      MX      10 ${mailServer}.
                       IN      TXT     "v=spf1 mx ~all"
          default._domainkey IN TXT ${dkimTxt}
          _dmarc IN TXT ${dmarcPolicy}

          mail         IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}

          lists        IN      MX      10 ${mailServer}.
                       IN      TXT     "v=spf1 mx ~all"
          default._domainkey.lists IN TXT ${dkimTxt}
          _dmarc.lists IN TXT ${dmarcPolicy}

          bots         IN      MX      10 ${mailServer}.
                       IN      TXT     "v=spf1 mx ~all"
          default._domainkey.bots IN TXT ${dkimTxt}
          _dmarc.bots  IN TXT ${dmarcPolicy}

          headscale    IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}

          monit        IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}

          huannouncementbot IN      A       ${vflower.ipv4}
                            IN      AAAA    ${vflower.ipv6}

          hucafeteriabot IN      A       ${vflower.ipv4}
                         IN      AAAA    ${vflower.ipv6}

          mumble       IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}

          ns0          IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}

          bitirme      IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}

          ragopedia    IN      A       ${vflower.ipv4}
                       IN      AAAA    ${vflower.ipv6}
 
          ragopedia-api IN      A       ${vflower.ipv4}
                        IN      AAAA    ${vflower.ipv6}
        '';
      };
    };
  };
}
