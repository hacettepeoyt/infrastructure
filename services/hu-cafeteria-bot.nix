{ config, pkgs, ... }: 
let
  version = "2.1.0";

  pkg = pkgs.stdenv.mkDerivation {
    pname = "hu-cafeteria-bot";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "hacettepeoyt";
      repo = "hu-cafeteria-bot";
      rev = "v${version}";
      hash = "sha256-rVswyICPMNS6HnnpcixEPtFc1mn3ogs9nrPBZNizCoQ=";
    };

    buildInputs = with pkgs; [
      python311
      python311Packages.aiohttp
      python311Packages.pillow
      python311Packages.python-telegram-bot
      python311Packages.pytz
      python311Packages.toml
    ];

    patchPhase = ''
      sed -i -r -e 's|database.json|/var/lib/hu-cafeteria-bot/database.json|g' src/bot.py
      sed -i -r -e 's|menu.png|/var/lib/hu-cafeteria-bot/menu.png|g' src/bot.py src/image.py
    '';

    installPhase = ''
      cp -r . $out
    '';
  };

  python = pkgs.python311.withPackages (ppkgs: pkg.buildInputs);
in
{
  systemd.services.hu-cafeteria-bot = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    startLimitBurst = 3;
    startLimitIntervalSec = 60;

    serviceConfig = {
      # ExecStart = "/run/current-system/sw/bin/bash -c 'python ${pkg}/src/bot.py /etc/hu-cafeteria-bot.toml'";
      # ExecStart = "${pkgs.python311}/bin/python ${pkg}/src/bot.py /etc/hu-cafeteria-bot.toml";
      ExecStart = "${python}/bin/python -m src ${config.age.secrets.hu-cafeteria-bot.path}";

      Restart = "always";
      WorkingDirectory = "${pkg}";
      User = "hu-cafeteria-bot";
      Group = "hu-cafeteria-bot";
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

  users.users.hu-cafeteria-bot = {
    isSystemUser = true;
    home = "/var/lib/hu-cafeteria-bot";
    createHome = true;
    homeMode = "770";
    group = "hu-cafeteria-bot";
    packages = pkg.buildInputs;
  };
    
  users.groups.hu-cafeteria-bot = { };
}
