{
  pkgs,
  config,
  lib,
  isCask,
  ...
}:
# Ghostty is a fast, feature-rich, and cross-platform terminal emulator that
# uses platform-native UI and GPU acceleration.
let
  brewed = isCask "ghostty";

  default_prog =
    if config.programs.fish.enable
    then "${config.programs.fish.package}/bin/fish"
    else "${config.programs.zsh.package}/bin/zsh";

  settings = {
    theme = "light:dawnfox,dark:Mellifluous";
    font-size = 13;
    command = "${default_prog}";
    config-file = "?override"; # config file `./override` is optional
    macos-option-as-alt = "left";
    adjust-cell-width = "-5%"; # slightly narrower
    window-padding-balance = "true";
  };

  # Ghostty theme files ported from the Palebloom JetBrains IDE theme
  # Source: https://github.com/palebloom/palebloom-jetbrains
  themes = {
    Palebloom = {
      palette = [
        "0=#1a1a21"
        "1=#ffa1b1"
        "2=#b9e1c6"
        "3=#f7fbc6"
        "4=#aacefa"
        "5=#cdbbff"
        "6=#b8f1f9"
        "7=#eaeaff"
        "8=#494957"
        "9=#ffa1b1"
        "10=#b9e1c6"
        "11=#f7fbc6"
        "12=#aacefa"
        "13=#cdbbff"
        "14=#b8f1f9"
        "15=#eaeaff"
      ];
      background = "#272730";
      foreground = "#eaeaff";
      cursor-color = "#eaeaff";
      selection-background = "#494957";
      selection-foreground = "#eaeaff";
    };

    PalebloomNight = {
      palette = [
        "0=#121216"
        "1=#ffa1b1"
        "2=#b9e1c6"
        "3=#f7fbc6"
        "4=#aacefa"
        "5=#cdbbff"
        "6=#b8f1f9"
        "7=#eaeaff"
        "8=#343440"
        "9=#ffa1b1"
        "10=#b9e1c6"
        "11=#f7fbc6"
        "12=#aacefa"
        "13=#cdbbff"
        "14=#b8f1f9"
        "15=#eaeaff"
      ];
      background = "#1a1a21";
      foreground = "#eaeaff";
      cursor-color = "#eaeaff";
      selection-background = "#343440";
      selection-foreground = "#eaeaff";
    };
  };
in
  lib.mkMerge [
    {
      programs.ghostty.enable = !brewed;
    }
    (lib.mkIf (!brewed) {
      programs.ghostty.settings = settings;
      programs.ghostty.themes = themes;
    })
    (lib.mkIf brewed {
      # use homebrew's ghostty, set main config and themes by ourselves
      xdg.configFile =
        {
          "ghostty/config".source = (pkgs.formats.keyValue {
            # support duplicate keys
            listsAsDuplicateKeys = true;
            # key = value
            mkKeyValue = lib.generators.mkKeyValueDefault {} " = ";
          }).generate "ghostty-config"
          settings;
        }
        // lib.mapAttrs' (name: theme:
          lib.nameValuePair "ghostty/themes/${name}" {
            source = (pkgs.formats.keyValue {
              listsAsDuplicateKeys = true;
              mkKeyValue = lib.generators.mkKeyValueDefault {} " = ";
            }).generate "ghostty-theme-${name}"
            theme;
          })
        themes;
    })
  ]
