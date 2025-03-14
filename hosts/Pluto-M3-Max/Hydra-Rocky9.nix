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
        ({
          config,
          pkgs,
          ...
        }: {
          brewery.enable = false;

          home.packages = with pkgs; [
            dust
            fastfetch
            fd
            nodejs
            ripgrep

            # C++ environment
            gcc13
            clang-tools
            cmake
          ];

          # Reuse MacOS's fonts
          xdg.dataFile."fonts/mac-fon".source =
            config.lib.file.mkOutOfStoreSymlink
            "/mnt/mac/Users/${config.home.username}/Library/Fonts";
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
