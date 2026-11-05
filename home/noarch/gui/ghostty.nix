{
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
    # Note that shell integration will automatically set the cursor to a bar at a prompt, regardless of this configuration.
    # You can disable that behavior by specifying shell-integration-features = no-cursor or disabling shell integration entirely.
    shell-integration-features = "no-cursor,";
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
in {
  programs.ghostty = {
    enable = true;
    # Keep Home Manager's configuration generation without installing a Nix package.
    package = lib.mkIf brewed null;
    inherit settings themes;
  };
}
