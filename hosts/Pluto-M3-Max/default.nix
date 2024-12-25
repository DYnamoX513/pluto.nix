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
      (
        {pkgs, ...}: {
          homebrew = {
            onActivation = {
              # autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
              # upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
              # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
              cleanup = "zap";
            };

            taps = [
              # "messense/macos-cross-toolchains"
            ];

            # `brew install`
            brews = [
              "go"
              # "pyenv" checkout uv -> https://docs.astral.sh/uv/
              # "x86_64-unknown-linux-gnu" # cross compiler
              "zellij" # terminal multiplexer
            ];

            # `brew install --cask`
            casks = [
              # Amazon OpenJDK 8 (arm64)
              "corretto@8" # openjdk@8, temurin@8, etc. require x86_64 arch
              # Eclipse Temurin
              "temurin"
            ];
          };
        }
      )
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
