{ pkgs, ... }: {
  systemd.services.minecraft-server = {
    enable = false;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    startLimitBurst = 3;
    startLimitIntervalSec = 60;

    serviceConfig = {
      ExecStart = "/etc/profiles/per-user/minecraft/bin/minecraft-server";

      Restart = "always";
      WorkingDirectory = "/srv/minecraft";
      User = "minecraft";
      Group = "minecraft";
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

  users.users.minecraft = {
    isSystemUser = true;
    home = "/srv/minecraft";
    createHome = true;
    homeMode = "770";
    group = "minecraft";
    packages = [ pkgs.papermc ];
  };

  users.groups.minecraft = { };

  security.sudo.extraRules = [
    {
      groups = [ "minecraft" ];
      commands = [
        "/run/current-system/sw/bin/systemctl start minecraft-server"
        "/run/current-system/sw/bin/systemctl stop minecraft-server"
        "/run/current-system/sw/bin/systemctl restart minecraft-server"
        "/run/current-system/sw/bin/journalctl -eu minecraft-server"
      ];
    }
  ];

  nixpkgs.overlays = [
    ( final: prev: {
        papermc = prev.papermc.overrideAttrs (finalAttrs: previousAttrs: {
          version = "1.20.2.234";

          src =
            let
              mcVersion = prev.lib.versions.pad 3 finalAttrs.version;
              buildNum = builtins.elemAt (prev.lib.splitVersion finalAttrs.version) 3;
            in
            prev.fetchurl {
              url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
              hash = "sha256-fR7Dq09iFGVXodQjrS7Hg4NcrKPJbNg0hexU520JC6c=";
            };
        });
    })
  ];
}
