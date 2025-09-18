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
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    # home-manager complains that `home-manager.users.pluto.home.homeDirectory' is not of type `path'
    # if users.users.<username>.home is not set in nix-darwin
    # See https://github.com/nix-community/home-manager/issues/6036
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];

  # Since 25.11, some nix-darwin options apply to the `primaryUser` instead of the user running `darwin-rebuild`.
  system.primaryUser = username;
}
