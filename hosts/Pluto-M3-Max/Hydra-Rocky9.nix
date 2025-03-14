{mkLinuxConfig}:
##########################################################################
#
#  Hydra - Rocky Linux 9 (OrbStack VM) inside of MacBook Pro 16-inch
#
##########################################################################
let
  hostname = "Hydra-Rocky9";
  system = "aarch64-linux";
  modules = {
    extra-modules = [];
    home-modules =
      [
        ({...}: {
          brewery.enable = false;
        })
      ]
      ++ import ../../home/collect-home-modules.nix {
        noGui = true;
        noCli = false;
        ageSecrets = false;
        # Linux
        isDarwin = false;
      };
  };
in {
  nixosConfiguration.${hostname} = mkLinuxConfig {
    inherit system hostname;
    inherit (modules) extra-modules home-modules;
  };
}
