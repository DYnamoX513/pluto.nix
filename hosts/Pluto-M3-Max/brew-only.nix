{ config, lib, ... }:
# use homebrew exclusively on Darwin
let
  # brew and cask packages
  homebrewPackages = config.homebrew.brews ++ config.homebrew.casks;

# extra mappings brew -> HM
  hmToBrewPackages = {
    "wezterm" = "wezterm";
    "wezterm@nightly" = "wezterm";
  };

    # set each HM program's package to null
  nullifyHomebrewPackages = programs:
    lib.attrsets.mapAttrs 
      (name: value: 
        if builtins.any 
          (pkg: pkg == name || 
           (builtins.hasAttr name hmToBrewPackages && 
            hmToBrewPackages.${name} == pkg)) 
          homebrewPackages
        then value // { package = null; }
        else value
      ) 
      programs;
in {
  programs = nullifyHomebrewPackages config.programs;
}
