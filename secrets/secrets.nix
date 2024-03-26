let
  serverPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXqBeVR2JHYUatQYM4cy03MKmkotHhR2drHJfzKi/Nl";

  conf = (import ../system.nix) { config = {}; libs = {}; pkgs = {}; };

  # A normal user to ssh key mapping. Automated way of declaring the following using the authorizedKeys from configuration.nix:
  # users = {
  #   div72 = [ "ssh-ed25519 ..." ];
  #   ...
  # };
  userKeys = builtins.listToAttrs (map (user: { name = user; value = conf.users.users."${user}".openssh.authorizedKeys.keys; }) (builtins.filter (user: ({ isNormalUser = false; } // conf.users.users."${user}").isNormalUser) (builtins.attrNames conf.users.users)));
in

# Add all user passwords as secrets:
builtins.listToAttrs (map (user: { name = "passwd/${user}.age"; value = { publicKeys = userKeys."${user}" ++ [ serverPublicKey ] ++ userKeys.div72; }; }) (builtins.attrNames userKeys)) //

{
  "services/hu-cafeteria-bot.age".publicKeys = [ serverPublicKey ] ++  userKeys.div72 ++ userKeys.f1nch;
  "services/hu-announcement-bot.age".publicKeys = [ serverPublicKey ] ++  userKeys.div72 ++ userKeys.f1nch;
  "services/oyt-website.age".publicKeys = [ serverPublicKey ] ++  userKeys.div72 ++ userKeys.f1nch;
}
