{ config, pkgs, ... }:
let
  version = "2.4";

  pkg = pkgs.stdenv.mkDerivation {
    pname = "oyt-website";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "hacettepeoyt";
      repo = "oyt-website";
      rev = "v${version}";
      hash = "sha256-qDpQ09RSn05YZ3HaOJVrKZ0i1+W2nL4lr/lar1DpY20=";
    };

    buildInputs = with pkgs; [
      python311
      python311Packages.django
      python311Packages.django-crispy-bootstrap5
      python311Packages.django-crispy-forms
      python311Packages.django-simple-captcha
      python311Packages.pillow
      python311Packages.requests
    ];

    installPhase = ''
      cp -r . $out
    '';
  };

  python = pkgs.python311.withPackages (ppkgs: pkg.buildInputs);
in
{
  services.nginx.virtualHosts."www.ozguryazilimhacettepe.com" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "ozguryazilimhacettepe.com";
  };

  services.nginx.virtualHosts."ozguryazilimhacettepe.com" = {
    enableACME = true;
    forceSSL = true;

    locations = {
      "/" = {
        proxyPass = "http://localhost:31416";
      };

      "/static" = {
        root = "${pkg}/oytwebsite";
      };

      "/static/admin" = {
        root = "${pkgs.python311Packages.django}/lib/python3.11/site-packages/django/contrib/admin";
      };

      "/media" = {
        root = "/var/lib/oyt-website";
      };
    };
  };

  systemd.services.oyt-website = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    startLimitBurst = 3;
    startLimitIntervalSec = 60;

    environment = {
      CONFIG_FILE = "${config.age.secrets.oyt-website.path}";
    };

    serviceConfig = {
      ExecStartPre = "${python}/bin/python oytwebsite/manage.py migrate";
      ExecStart = "${python}/bin/python oytwebsite/manage.py runserver";

      Restart = "always";
      WorkingDirectory = "${pkg}";
      User = "oyt-website";
      Group = "oyt-website";
      Type = "simple";

      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0027";
    };
  };

  users.users.oyt-website = {
    isSystemUser = true;
    home = "/var/lib/oyt-website";
    createHome = true;
    homeMode = "750";
    group = "oyt-website";
    packages = pkg.buildInputs;
  };
    
  users.groups.oyt-website = {
    members = [ "oyt-website" "nginx" ];
  };
}
