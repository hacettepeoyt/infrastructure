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

    trap "exit" INT TERM
    trap "kill 0" EXIT

    ${lib.getExe pkgs.tmux} new-session "${chatRead} $CHAT_FILE" \; \
                            split-window -p 20 -v "${chatWrite} $CHAT_FILE"  
  '';
in
{
  environment.systemPackages = [ chat ];
}
