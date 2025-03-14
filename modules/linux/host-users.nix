{
  username,
  hostname,
  ...
}:
#############################################################
#
#  Host & Users configuration
#
#############################################################
{
  networking.hostName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    # home-manager complains that `home-manager.users.pluto.home.homeDirectory' is not of type `path'
    # if users.users.<username>.home is not set in nix-darwin
    # See https://github.com/nix-community/home-manager/issues/6036
    home = "/Users/${username}";
    group = "${username}";
    description = username;

    isNormalUser = true;
  };

  nix.settings.trusted-users = [username];
}
