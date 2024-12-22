{config, ...}: let
  # the path to helix directory
  configPath = "${config.home.homeDirectory}/pluto.nix/share/helix";
in {
  xdg.configFile."helix".source = config.lib.file.mkOutOfStoreSymlink configPath;
  programs.helix.enable = true;
}
