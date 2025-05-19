{ lib, pkgs, ... }: let
  pythonEnv = pkgs.python3.withPackages (pp: [ pp.requests ]);

  systemdRunWrapper = pkgs.writeShellScript "faceless_systemd_run" ''
    USER="$1"
    shift 1

    if getent passwd "$USER"; then
      echo "$0: $USER exists on the system, refusing to run."
      exit 1
    fi

    echo "$0: Running $@"
    exec ${pkgs.systemd}/bin/systemd-run --pty \
      --property=DynamicUser=yes \
      --property=User=$USER \
      --property=Group=$USER \
      --property=ProtectHome=yes \
      --property=ProtectSystem=yes \
      --property=PrivateNetwork=yes \
      --property=PrivateTmp=yes \
      --property=WorkingDirectory=/tmp \
      --property=ReadWriteDirectories=/var/lib/chat \
      /usr/bin/env PATH="$PATH" "$@"
  '';

  facelessMain = pkgs.writeScript "faceless" ''
    #! ${pythonEnv.interpreter}

    import base64
    import os
    import pwd
    import string
    import sys

    import requests

    supplied_ssh_key = sys.argv[1] + " " + sys.argv[2]

    print("faceless: Attempting login with GitHub.")
    username = input("GitHub Username: ")

    if len(username) > 16:
      print("faceless: Ignoring username longer than 16 characters.")
      exit(1)

    if not all(ch in (string.ascii_letters + string.digits + '_-') for ch in username):
      print("faceless: Ignoring username with weird characters.")
      exit(1)

    try:
      pwd.getpwnam(username)
      print(f"faceless: {username} exists on the system, refusing to run.")
      exit(1)
    except KeyError:
      pass

    resp = requests.get(f"https://github.com/{username}.keys")

    if not resp.ok:
      print("faceless: GH returned non-zero exit code.")
      exit(1)

    print(f"faceless: Supplied key: {supplied_ssh_key}")

    match = False
    for gh_key in resp.text.splitlines():
      print(f"faceless: Checking key {gh_key}")
      gh_key = gh_key.strip()

      if gh_key == supplied_ssh_key:
        match = True
        break

    if not match:
      print(f"faceless: Key did not match any key on https://github.com/{username}.keys")
      exit(1)

    print("faceless: Authorization complete. You'll now be redirected to a restricted shell.")
    print("faceless: Please behave.")

    os.execl(
      "/run/wrappers/bin/sudo",
      "--",
      "${systemdRunWrapper}",
      username,
      os.environ.get("SSH_ORIGINAL_COMMAND", "${pkgs.bashInteractive}/bin/bash"),
    )
  '';

  facelessAuthorizedKeyCommand = pkgs.writeShellScript "faceless_authorized_key" ''
    KEY_TYPE="$1"
    SSH_KEY="$2"

    echo restrict,pty,command='"'${facelessMain} $KEY_TYPE $SSH_KEY'"' $KEY_TYPE $SSH_KEY
  '';
in {
  users.users.faceless.isSystemUser = true;
  users.users.faceless.shell = pkgs.bashInteractive;
  users.users.faceless.group = "faceless";
  users.groups.faceless = {};

  security.sudo.extraRules = [
    {
      users = ["faceless"];
      groups = ["faceless"];
      commands = [
        { command = "${systemdRunWrapper}"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  security.wrappers.faceless-authorized-key = {
    owner = "root";
    group = "root";
    source = facelessAuthorizedKeyCommand;
  };

  services.openssh.extraConfig = ''
    Match User faceless
    AuthorizedKeysCommand /run/wrappers/bin/faceless-authorized-key "%t" "%k"
    AuthorizedKeysCommandUser faceless
    PasswordAuthentication no
    Match all
  '';
}
