{mkDarwinConfig, ...}:
#############################################################
#
#  Pluto - MacBook Pro 16-inch, Nov 2023
#  Chip: M3 Max
#  RAM: 48G
#  SSD: 1T
#
#############################################################
let
  hostname = "Pluto-M3-Max";
  system = "aarch64-darwin";
  modules = {
    extra-modules = [
      # ./host-specifix.nix
    ];
    home-modules = [
      # ./home-specifix.nix
      ../../home
    ];
  };
in {
  darwinConfiguration.${hostname} = mkDarwinConfig {
    inherit system hostname;
    inherit (modules) extra-modules home-modules;
  };
}
