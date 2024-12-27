{config, ...}: let
  # the path to helix directory
  configPath = "${config.home.homeDirectory}/pluto.nix/share/helix";
  brewed = builtins.elem "helix" config.brewery.rules.brewList;
in {
  xdg.configFile."helix".source = config.lib.file.mkOutOfStoreSymlink configPath;
  programs.helix.enable = !brewed;
}
