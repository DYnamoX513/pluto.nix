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
in
  lib.mkMerge [
    {
      programs.ghostty.enable = !brewed;
    }
    (lib.mkIf (!brewed)
      {
        programs.ghostty.settings = settings;
      })
    (lib.mkIf brewed {
      # use homebrew's ghostty, set main config by ourselves
      xdg.configFile."ghostty" = {
        target = "ghostty/config";
        source =
          (pkgs.formats.keyValue {
            # support duplicate keys
            listsAsDuplicateKeys = true;
            # key = value
            mkKeyValue = lib.generators.mkKeyValueDefault {} " = ";
          }).generate "ghostty-config"
          settings;
      };
    })
  ]
