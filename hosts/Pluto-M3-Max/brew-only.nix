{ config, osConfig, lib, pkgs, ... }:
# use homebrew exclusively on Darwin
let
  # brew and cask packages
brewNames = builtins.map (brew: brew.name) osConfig.homebrew.brews;
caskNames = builtins.map (brew: brew.name) osConfig.homebrew.casks;
  homebrewPackages = brewNames ++ caskNames;

# extra mappings brew -> HM
  hmToBrewPackages = {
    "wezterm" = "wezterm";
    "wezterm@nightly" = "wezterm";
  };

    mkGhostPackage = name: pkgs.emptyDirectory // {
          meta = pkgs.emptyDirectory.meta // {
            mainProgram = pkgs.${name}.meta.mainProgram;
          };
        };

in {
    # set each HM program's package to null

    ### This trick may not work for some packages...
    ### https://github.com/nix-community/home-manager/issues/4763 ###

programs = lib.mapAttrs 
    (name: value: 
      if builtins.hasAttr "package" value
      then {
        package = lib.mkOverride 999 (mkGhostPackage name);
      }
      else {})
    (lib.filterAttrs
      (name: _:
        builtins.any 
          (pkg: pkg == name || 
           (builtins.hasAttr name hmToBrewPackages && 
            hmToBrewPackages.${name} == pkg)) 
          homebrewPackages)
      config.programs) // {
        # fzf needs a version to check shell integration
        # https://github.com/nix-community/home-manager/blob/1395379a7a36e40f2a76e7b9936cc52950baa1be/modules/programs/fzf.nix#L13
        # ```
        # hasShellIntegrationEmbedded = lib.versionAtLeast cfg.package.version "0.48.0";
        # ```
            fzf.package = mkGhostPackage "fzf" // {version = "0.56.0";}; # homebrew's stable fzf
        };

}
