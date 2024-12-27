{
  config,
  osConfig,
  scanPaths,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.brewery;
in {
  # import sub modules
  imports = scanPaths ./.;

  options.brewery = {
    enable = mkOption {
      default = true;
      type = types.bool;
      description = ''
        When enabled, if a package is both enabled in home-manager and homebrew (either as a formula or cask),
        it will be disabled in home-manager and the configuration phase is manually controlled by each
        submodule.
      '';
    };

    rules = mkOption {
      type = types.submodule {
        options = {
          brewList = mkOption {
            default = [];
            type = types.listOf types.str;
            description = "A list of homebrew formulae. Extracted from nix-darwin config.";
          };

          caskList = mkOption {
            default = [];
            type = types.listOf types.str;
            description = "A list of homebrew casks. Extracted from nix-darwin config.";
          };
        };
      };
      default = {
      };
    };
  };

  config.brewery.rules = lib.mkIf (pkgs.stdenv.isDarwin && cfg.enable) {
    brewList = builtins.map (brew: brew.name) osConfig.homebrew.brews;
    caskList = builtins.map (cask: cask.name) osConfig.homebrew.casks;
  };
}
