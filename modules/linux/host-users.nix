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
    home = "/home/${username}";
    group = "${username}";
    description = username;

    isNormalUser = true;
  };

  users.groups."${username}" = {};

  nix.settings.trusted-users = [username];
}
