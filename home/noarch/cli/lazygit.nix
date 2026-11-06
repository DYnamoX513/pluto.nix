{
  lib,
  userfullname,
  isFormula,
  ...
}: let
  brewed = isFormula "lazygit";
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
        authorColors = {
          # "Yuxin Duan" = "#30A0A0";
          ${userfullname} = "#30A0A0";
        };
      };
    };
    confirmOnQuit = true;
  };
in {
  programs.lazygit = {
    enable = true;
    # The upstream module handles both Darwin's native path and XDG paths.
    package = lib.mkIf brewed null;
    inherit settings;
  };
}
