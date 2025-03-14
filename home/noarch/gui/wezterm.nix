{
  config,
  lib,
  isCask,
  ...
}:
# WezTerm is a powerful cross-platform terminal emulator and multiplexerwritten
# written by @wez and implemented in Rust
# see https://wezfurlong.org/wezterm/index.html
let
  brewed = isCask "wezterm" || isCask "wezterm@nightly";
  # the path to wezterm lua directory
  luaConfigPath = "${config.home.homeDirectory}/pluto.nix/share/wezterm/lua";

  default_prog =
    if config.programs.fish.enable
    then "${config.programs.fish.package}/bin/fish"
    else "${config.programs.zsh.package}/bin/zsh";
  # all color_schemes: https://wezfurlong.org/wezterm/colorschemes/index.html
  color_scheme = "N0tch2k";

  # for both UI and terminal
  font_size = 13;

  mainConfig = ''
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
in
  lib.mkMerge [
    {
      programs.wezterm.enable = !brewed;
      # config lua directory
      xdg.configFile."wezterm_lua" = {
        target = "wezterm/lua";
        source = config.lib.file.mkOutOfStoreSymlink luaConfigPath;
      };

      # no enableFishIntegration for wezterm (24.11)
      programs.fish.interactiveShellInit = ''
        eval "$(wezterm shell-completion --shell fish)"
      '';
    }
    (lib.mkIf (!brewed)
      {
        programs.wezterm.extraConfig = mainConfig;
      })
    (lib.mkIf brewed {
      # use homebrew's wezterm@nightly, set main config by ourselves
      xdg.configFile."wezterm" = {
        target = "wezterm/wezterm.lua";
        text = mainConfig;
      };
    })
  ]
