{username, ...}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.homeDirectory = "/home/${username}";
}
