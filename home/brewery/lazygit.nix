{
  config,
  pkgs,
  lib,
  userfullname,
  isFormula,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  brewed = isFormula "lazygit";
  yamlFormat = pkgs.formats.yaml {};
  settings = {
    gui = {
      nerdFontsVersion = "3";
      spinner = {
        frames = [
          "'"
          "°"
          "º"
          "¤"
          "ø"
          ","
          "¸"
          "¸"
          ","
          "ø"
          "¤"
          "º"
          "°"
          "'"
        ];
      };
      theme = {
        selectedLineBgColor = [
          "reverse"
        ];
      };
      authorColors = {
        # "Yuxin Duan" = "#30A0A0";
        ${userfullname} = "#30A0A0";
      };
    };
    confirmOnQuit = true;
  };
in
  lib.mkMerge [
    {
      # use nixpkgs-lazygit only if it's not added to brew list
      programs.lazygit.enable = !brewed;
    }
    (lib.mkIf (!brewed) {
      programs.lazygit = {
        inherit settings;
      };
    })
    (lib.mkIf (brewed && !config.xdg.enable && settings != {}) {
      home.file."Library/Application Support/lazygit/config.yml" = lib.mkIf isDarwin {
        source = yamlFormat.generate "lazygit-config" settings;
      };

      # Redundant: if brewed, we're guaranteed that isDarwin == true
      xdg.configFile."lazygit/config.yml" = lib.mkIf (!isDarwin) {
        source = yamlFormat.generate "lazygit-config" settings;
      };
    })
  ]
