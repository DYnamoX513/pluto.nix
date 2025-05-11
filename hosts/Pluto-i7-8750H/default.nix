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
    config-modules = [
      ../../modules/darwin
      (
        _: {
          homebrew = {
            onActivation = {
              # autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
              # upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
              # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
              # cleanup = "zap";
            };

            # `brew install --cask`
            casks = [
              # Derived from IBM Plex Mono, with ligature
              # "font-lilex"
              # "font-lilex-nerd-font"
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
    home-modules = import ../../home/collect-home-modules.nix {
      noGui = false;
      noCli = false;
      ageSecrets = true;
      isDarwin = true;
    };
  };
in {
  darwinConfiguration.${hostname} = mkDarwinConfig (modules // {inherit system hostname;});
}
