{mkDarwinConfig, ...}:
#############################################################
#
#  Pluto - MacBook Pro 15-inch, 2018
#  Chip: Intel® Core™ i7-8750H
#  RAM: 16G
#  SSD: 256G
#
#############################################################
let
  hostname = "Pluto-i7-8750H";
  system = "x86_64-darwin";
  modules = {
    extra-modules = [
      # ./host-specifix.nix
    ];
    home-modules = [
      # ./home-specifix.nix
      ../../home
      ../Pluto-M3-Max/brew-only.nix
    ];
  };
in {
  darwinConfiguration.${hostname} = mkDarwinConfig (modules // {inherit system hostname;});
}
