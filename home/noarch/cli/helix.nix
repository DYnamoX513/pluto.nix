{
  config,
  isFormula,
  ...
}: let
  # the path to helix directory
  configPath = "${config.home.homeDirectory}/pluto.nix/share/helix";
  brewed = isFormula "helix";
in {
  xdg.configFile."helix".source = config.lib.file.mkOutOfStoreSymlink configPath;
  programs.helix.enable = !brewed;
}
