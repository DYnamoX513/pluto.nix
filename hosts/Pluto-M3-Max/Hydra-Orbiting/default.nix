{mkNixosConfig}:
##########################################################################
#
#  Hydra - NixOS (OrbStack VM) inside of MacBook Pro 16-inch
#
##########################################################################
let
  hostname = "Hydra-Orbiting";
  system = "aarch64-linux";
  modules = {
    config-modules = [
      ./configuration.nix
      ./orbstack.nix
      ../../../modules/linux/environment.nix
    ];
    home-modules =
      [
        ({
          config,
          pkgs,
          ...
        }: {
          brewery.enable = false;

          home.packages = with pkgs; [
            btop
            dust
            fastfetch
            fd
            nodejs
            python3
            ripgrep
            uv

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
      ++ import ../../../home/collect-home-modules.nix {
        noGui = true;
        noCli = false;
        ageSecrets = false;
        # Linux
        isDarwin = false;
      };
  };
in {
  nixosConfiguration.${hostname} = mkNixosConfig {
    inherit system hostname;
    inherit (modules) config-modules home-modules;
  };
}
