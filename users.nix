{ config, pkgs }: {
  div72 = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.passwd-div72.path;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = [ ]; # packages managed by home-manager
    openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVb2l/23ykDnfhO5VrkCQaycfF9oCo1Jig/JeG86w//'' ];
  };

  ikolomiko = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.passwd-ikolomiko.path;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = [ pkgs.git pkgs.screen pkgs.vim pkgs.eza pkgs.htop pkgs.ncdu ];
    openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6fYwAAYEKncSRGjh+xVE8toRB4ztmBFDFX2wShZAPw'' ];
  };

  f1nch = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.passwd-f1nch.path;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = [
      pkgs.git pkgs.vim pkgs.nix-prefetch

      (pkgs.writeShellScriptBin "bump-cafeteria-bot" ''
        cd /etc/nixos

        set -e

        if [ ! -z "$(git status --porcelain)" ]; then
          echo "Somebody forgot to commit the changes! Exiting."
          exit 1
        fi

        if [ -z "$SSH_AUTH_SOCK" ]; then
          echo "You need to forward your SSH agent. (ssh -A ...)"
          exit 1
        fi

        sudo chgrp -R wheel /etc/nixos
        sudo chmod -R g+w /etc/nixos

        new_hash=$(nix-prefetch fetchFromGitHub --owner hacettepeoyt --repo hu-cafeteria-bot --rev "v$1")
        sed -i -r -e 's|hash = "sha256-[a-zA-Z0-9/=]+";|hash = "'"$new_hash"'";|g' /etc/nixos/services/hu-cafeteria-bot.nix
        sed -i -r -e 's|version = "[0-9.-]+";|version = "'"$1"'";|g' /etc/nixos/services/hu-cafeteria-bot.nix

        sudo nixos-rebuild switch
        git add /etc/nixos/services/hu-cafeteria-bot.nix
        git commit -m "services: bump hu-cafeteria-bot to $1"
        git push
      '')

      (pkgs.writeShellScriptBin "bump-announcement-bot" ''
        cd /etc/nixos

        set -e

        if [ ! -z "$(git status --porcelain)" ]; then
          echo "Somebody forgot to commit the changes! Exiting."
          exit 1
        fi

        if [ -z "$SSH_AUTH_SOCK" ]; then
          echo "You need to forward your SSH agent. (ssh -A ...)"
          exit 1
        fi

        sudo chgrp -R wheel /etc/nixos
        sudo chmod -R g+w /etc/nixos

        new_hash=$(nix-prefetch fetchFromGitHub --owner hacettepeoyt --repo hu-announcement-bot --rev "v$1")
        sed -i -r -e 's|hash = "sha256-[a-zA-Z0-9/=]+";|hash = "'"$new_hash"'";|g' /etc/nixos/services/hu-announcement-bot.nix
        sed -i -r -e 's|version = "[0-9.-]+";|version = "'"$1"'";|g' /etc/nixos/services/hu-announcement-bot.nix

        sudo nixos-rebuild switch
        git add /etc/nixos/services/hu-announcement-bot.nix
        git commit -m "services: bump hu-announcement-bot to $1"
        git push
      '')
    ];
    openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKjtQ/SbNBCTSWimPetOw4veFxXANwPNdprjFiEQa2O'' ];
  };
  mudrowe = {
    isNormalUser = true;
    shell = pkgs.zsh;
    packages = [ pkgs.git pkgs.screen pkgs.vim pkgs.eza pkgs.htop pkgs.ncdu ];
    openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2rG0DGvje9CL/MCiA78tbgvypUD1aLqQkHbo/PXAjL'' ];
  };
}
