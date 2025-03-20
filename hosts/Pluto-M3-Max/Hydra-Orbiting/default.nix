{
  mkNixosConfig,
  # nixpkgs-stable-24_11,
  ...
}:
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
      (
        {pkgs, ...}: {
          environment.systemPackages = with pkgs; [
            unzip
            wget
          ];

          users.defaultUserShell = pkgs.zsh;
          # https://github.com/nix-community/nix-ld
          # Run unpatched dynamic binaries on NixOS.
          programs.nix-ld.enable = true;
        }
      )
    ];
    home-modules =
      [
        ({
          config,
          pkgs,
          # pkgs-stable-24_11,
          ...
        }: {
          brewery.enable = false;

          home.packages =
            (with pkgs; [
              btop
              dust
              fastfetch
              fd
              nodejs
              python3
              ripgrep
              uv

              # common utilities
              rsync

              # C++ environment
              gcc13
              clang-tools
              cmake
              gnumake
            ])
            ++ [
              # gcc7 has been removed from unstable nixpkgs
              # pkgs-stable-24_11.gcc7 # For developing some programs using the old CICD pipeline
            ];

          # Reuse MacOS's fonts
          xdg.dataFile."fonts/mac-fonts".source =
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
    extra-nixpkgs = {
      # mapped to pkgs-* and merged into specialArgs
      # stable-24_11 = nixpkgs-stable-24_11;
    };
  };
}
