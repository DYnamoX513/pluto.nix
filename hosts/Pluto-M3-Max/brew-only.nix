{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
# Use homebrew exclusively on Darwin
# This bootstrapping breaks a lot of things
# e.g., most shell integrations as they use binary paths located in nix store
let
  # brew and cask packages
  brewNames = builtins.map (brew: brew.name) osConfig.homebrew.brews;
  caskNames = builtins.map (brew: brew.name) osConfig.homebrew.casks;
  homebrewPackages = brewNames ++ caskNames;
  isProgramInHomebrew = let
    # extra mappings brew -> HM
    hmToBrewPackages = {
      "wezterm@nightly" = "wezterm";
    };

    # find all programs that are installed by homebrew but have different names in home-manager
    extraPackages = builtins.filter (brew: builtins.elem brew homebrewPackages) (builtins.attrNames hmToBrewPackages);

    mergedPackages = homebrewPackages ++ (builtins.map (pkg: hmToBrewPackages.${pkg}) extraPackages);
  in
    prog: builtins.elem prog mergedPackages;

  emptyPackage = name:
    pkgs.emptyDirectory
    // {
      meta =
        pkgs.emptyDirectory.meta
        // {
          inherit (pkgs.${name}.meta) mainProgram;
        };
    };

  ghostPackages =
    lib.mapAttrs
    (name: value:
      if value ? package
      then {
        package = lib.mkOverride 999 (emptyPackage name);
      }
      else {})
    (lib.filterAttrs
      (
        # some shell integrations require the fish package during the build
        prog: _:
          prog
          != "fish"
          && isProgramInHomebrew prog
      )
      config.programs);
in {
  # set each HM program's package to null

  ### This trick may not work for some packages...
  ### https://github.com/nix-community/home-manager/issues/4763 ###

  programs =
    ghostPackages
    // {
      # fzf needs a version to check shell integration
      # https://github.com/nix-community/home-manager/blob/1395379a7a36e40f2a76e7b9936cc52950baa1be/modules/programs/fzf.nix#L13
      # ```
      # hasShellIntegrationEmbedded = lib.versionAtLeast cfg.package.version "0.48.0";
      # ```
      fzf.package = emptyPackage "fzf" // {version = "0.57.0";}; # homebrew's stable fzf (Dec 2024)
    };
}
