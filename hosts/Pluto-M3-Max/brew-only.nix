{ config, lib, ... }:
# use homebrew exclusively on Darwin
let
  # brew packages
  homebrewPackages = config.homebrew.brews;

# extra mappings brew -> HM
  hmToBrewPackages = {
    # "fish" = "fish";
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
