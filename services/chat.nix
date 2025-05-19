{ lib, pkgs, ... }: let
  chatRead = pkgs.writeShellScript "chat_read" ''
    USERNAME=$(whoami)
    CHAT_FILE="$1"

    trap "exit" INT TERM
    trap "kill 0" EXIT

    tail -F $CHAT_FILE | sed -e "s/$USERNAME/$USERNAME\a/g"
  '';

  chatWrite = pkgs.writeShellScript "chat_write" ''
    USERNAME=$(whoami)
    CHAT_FILE="$1"

    trap "exit" INT TERM
    trap "kill 0" EXIT

    while read -r -p "<$USERNAME> " msg; do
      echo "<$USERNAME> $msg" >> "$CHAT_FILE"
      reset
    done
  '';

  chat = pkgs.writeShellScriptBin "chat" ''
    set -euo pipefail

    cd /var/lib/chat
    CHAT_FILE="$1"
    SCREEN_CONF=$(mktemp)

    trap "exit" INT TERM
    trap "rm -f $SCREEN_CONF; kill 0" EXIT


    cat > "$SCREEN_CONF" <<EOF
    screen 1 ${chatRead} $CHAT_FILE
    split -h
    focus down
    screen 2 ${chatWrite} $CHAT_FILE
    resize 20%
    EOF

    ${lib.getExe pkgs.screen} -c "$SCREEN_CONF"
  '';
in
{
  environment.systemPackages = [ chat ];
}
