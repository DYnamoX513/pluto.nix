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
      (
        {pkgs, ...}: {
          homebrew = {
            onActivation = {
              # autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
              # upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
              # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
              cleanup = "zap";
            };

            # `brew install --cask`
            casks = [
              # GPU-accelerated terminal emulator, written in Rust
              "alacritty"
              # Derived from IBM Plex Mono, with ligature
              "font-lilex"
              "font-lilex-nerd-font"
              # Menu bar manager
              "jordanbaird-ice"
              "monitorcontrol"
              # Eclipse Temurin 8
              "temurin@8"
              # Vivaldi browser
              "vivaldi"
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
  darwinConfiguration.${hostname} = mkDarwinConfig (modules // {inherit system hostname;});
}
