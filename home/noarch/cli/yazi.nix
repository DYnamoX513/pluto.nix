{
  lib,
  isFormula,
  ...
}: let
  brewed = isFormula "yazi";
in {
  programs.yazi = {
    enable = true;
    package = lib.mkIf brewed null;
    shellWrapperName = "y";
    # Upstream wrappers invoke yazi through PATH, so they also work with Homebrew.
    enableFishIntegration = true;
    enableZshIntegration = true;
  };
}
