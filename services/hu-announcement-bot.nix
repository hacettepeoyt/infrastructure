{ config, pkgs, ... }: 
let
  version = "3.8.0";

  pkg = pkgs.stdenv.mkDerivation {
    pname = "hu-announcement-bot";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "hacettepeoyt";
      repo = "hu-announcement-bot";
      rev = "v${version}";
      hash = "sha256-r4/pFxoqdVp8lvCmJBzGKF9DXvM61fJccarQ3+uu+58=";
    };

    buildInputs = with pkgs; [
      python311
      python311Packages.aiohttp
      python311Packages.apscheduler
      python311Packages.beautifulsoup4
      python311Packages.dnspython
      python311Packages.lxml
      python311Packages.motor
      python311Packages.python-telegram-bot
      python311Packages.pytz
      python311Packages.toml
      python311Packages.tornado
    ];

    patchPhase = ''
      rm Makefile
    '';

    installPhase = ''
      cp -r . $out
    '';
  };

  python = pkgs.python311.withPackages (ppkgs: pkg.buildInputs);
in
{
  systemd.services.hu-announcement-bot = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    startLimitBurst = 3;
    startLimitIntervalSec = 60;

    serviceConfig = {
      ExecStart = "${python}/bin/python -m src ${config.age.secrets.hu-announcement-bot.path}";

      Restart = "always";
      WorkingDirectory = "${pkg}";
      User = "hu-announcement-bot";
      Group = "hu-announcement-bot";
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

  users.users.hu-announcement-bot = {
    isSystemUser = true;
    home = "/var/lib/hu-announcement-bot";
    createHome = true;
    homeMode = "770";
    group = "hu-announcement-bot";
    packages = pkg.buildInputs;
  };
    
  users.groups.hu-announcement-bot = { };
}
