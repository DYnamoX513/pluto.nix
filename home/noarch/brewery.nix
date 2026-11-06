{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.brewery;
in {
  options.brewery = {
    enable = mkOption {
      default = pkgs.stdenv.hostPlatform.isDarwin;
      type = types.bool;
      description = ''
        When enabled, modules can query the declared Homebrew formulae and casks
        to avoid installing the same package through Home Manager.
        Modules that support a null package can still manage configuration through
        Home Manager; other modules provide configuration and shell integration locally.
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
      default = {};
    };
  };

  config.brewery.rules = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.enable) {
    brewList = builtins.map (brew: brew.name or brew) osConfig.homebrew.brews;
    caskList = builtins.map (cask: cask.name or cask) osConfig.homebrew.casks;
  };

  # specialArgs = {};
}
