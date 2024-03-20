{ age, config, pkgs, ... }: 
let
  version = "1.0.0";

  pkg = pkgs.stdenv.mkDerivation {
    pname = "oyt-website";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "hacettepeoyt";
      repo = "oyt-website";
      rev = "v${version}";
      hash = "sha256-AAAA=";
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
  age.secrets.oyt-website = {
    file = secrets/services/oyt-website.age;
    owner = "oyt-website";
  };

  systemd.services.oyt-website = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    startLimitBurst = 3;
    startLimitIntervalSec = 60;

    environment = {
      CONFIG_FILE = "${age.secrets.oyt-website.path}";
    };

    serviceConfig = {
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
      UMask = "0007";
    };
  };

  users.users.oyt-website = {
    isSystemUser = true;
    home = "/var/lib/oyt-website";
    createHome = true;
    homeMode = "770";
    group = "oyt-website";
    packages = pkg.buildInputs;
  };
    
  users.groups.oyt-website = { };
}
