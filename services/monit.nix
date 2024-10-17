{ config, pkgs, ... }:
let
  monitPort = "2812";
  checkSystemdUnits = pkgs.writeShellScript "check_systemd_units" ''
    if systemctl list-units --failed | grep -q failed; then
      systemctl list-units --failed
      exit 1
    fi
  '';
in
{
  services.nginx.virtualHosts."monit.tlkg.org.tr" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:${monitPort}";
  };

  services.monit = {
    enable = true;
    config = ''
      set daemon 60
      set httpd port ${monitPort}
        read-only
        allow localhost

      set mailserver localhost port 2525
      set mail-format { from: monit@bots.tlkg.org.tr }
      set alert sysadmin@lists.tlkg.org.tr

      check system $HOST
        if loadavg (15min) > 15 for 5 times within 15 cycles then alert
        if memory usage > 80% for 4 cycles then alert
        if swap usage > 20% for 4 cycles then alert

      check filesystem rootfs with path ${config.fileSystems."/".device}
        if space usage > 80% then alert

      check filesystem bootfs with path ${config.fileSystems."/boot".device}
        if space usage > 80% then alert

      check network eth0 with interface eth0
        if saturation > 50% then alert
        if total downloaded > 10 GB in last day then alert
        if total uploaded > 10 GB in last day then alert

      check program check_systemd_units PATH ${checkSystemdUnits}
        if status > 0 then alert

      check host formie address formie.div72.xyz
        if failed
          port 443
          protocol https
          request /forms/
        then alert
        alert formie-status@div72.xyz

      check host intin address intin.com.tr
        if failed
          port 443
          protocol https
        then alert

      check host oytwebsite address ozguryazilimhacettepe.com
        if failed
          port 443
          protocol https
        then alert

      check host fath address foldingathome.div72.xyz
        if failed
          port 443
          protocol https
        then alert

      check host ikooskar_cloudauth address ikooskar.com.tr
        if failed
          port 80
          protocol http
          request /api/v4/ip
        then alert
        alert ikolomiko@gmail.com
    '';
  };

  # TODO: Add service.monit.package option to nixpkgs.
  nixpkgs.overlays = [
    (final: prev: {
      monit = prev.monit.overrideAttrs (prevAttrs: {
        patches = (prev.lib.optionals (prevAttrs ? patches) prevAttrs.patches) ++ [ ../patches/monit/fix-row-alignment.patch ];
      });
    })
  ];
}
