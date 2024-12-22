{
  config,
  osConfig,
  pkgs,
  ...
}:
# WezTerm is a powerful cross-platform terminal emulator and multiplexerwritten
# written by @wez and implemented in Rust
# see https://wezfurlong.org/wezterm/index.html
let
  # the path to wezterm lua directory
  configPath = "${config.home.homeDirectory}/pluto.nix/share/wezterm/lua";
  default_prog =
    if (builtins.elem "fish" osConfig.homebrew.brews)
    then "${osConfig.homebrew.brewPrefix}/fish"
    else if config.programs.fish.enable
    then "${pkgs.fish}/bin/fish"
    else "${pkgs.zsh}/bin/zsh";
  # all ccolor_schemes: https://wezfurlong.org/wezterm/colorschemes/index.html
  color_scheme = "N0tch2k";

  # for both UI and terminal
  font_size = 13;
in {
  xdg.configFile."wezterm" = {
    target = "wezterm/lua";
    source = config.lib.file.mkOutOfStoreSymlink configPath;
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      -- Pull in the wezterm API
      local wezterm = require("wezterm")

      -- This will hold the configuration.
      local config = wezterm.config_builder()

      -- Spawn a fish/zsh shell in login mode
      config.default_prog = { "${default_prog}", "-l" }

      config.color_scheme = "${color_scheme}"

      local uni_font_size = ${toString font_size}
      config.font_size = uni_font_size
      config.font = wezterm.font_with_fallback({
      	"Iosevka Term SS08 Extended",
      	-- "Symbols Nerd Font", -- already bundled with wezterm
      	"PingFang SC", -- MacOS only 你好
      })

      config.window_frame = {
      	font = wezterm.font({ family = "IBM Plex Sans" }),
      	font_size = uni_font_size,
      }

      -- other configurations, may overwrite previous ones
      require("lua.core").setup(config)

      -- and finally, return the configuration to wezterm
      return config
    '';
  };
}
