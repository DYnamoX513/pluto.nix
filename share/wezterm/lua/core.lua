-- Pull in the wezterm API
local wezterm = require("wezterm")

local M = {}

-- This is where you actually apply your config choices

function M.setup(config)
	-- config.default_prog = { "/opt/homebrew/bin/fish", "-l" }

	-- config.color_scheme = "Railscasts (base16)"
	-- config.color_scheme = "iceberg-dark"
	-- config.color_scheme = "N0tch2k"

	-- local uni_font_size = 13.0
	-- config.font_size = uni_font_size
	-- config.font = wezterm.font_with_fallback {
	--   { family = "Iosevka Term SS08 Extended", scale = 1.00 },
	--   -- "IBM Plex Mono",
	--   -- "Input Mono Narrow",
	--   -- "Symbols Nerd Font", -- already bundled with wezterm
	--   "PingFang SC", -- MacOS only 你好
	-- }

	-- config.window_frame = {
	--   font = wezterm.font { family = "IBM Plex Sans" },
	--   font_size = uni_font_size,
	-- }

	-- config.line_height = 1.0
	config.cell_width = 0.9 -- more compact horizontally

	config.tab_bar_at_bottom = true
	config.window_padding = {
		left = 2,
		right = 2,
		top = 2,
		bottom = 2,
	}

	config.initial_cols = 120
	config.initial_rows = 30

	-- CTRL + SHIFT + <SPACE> conflict with MacOS's 'Select the previous input source'
	config.keys = {
		{ key = "s", mods = "SHIFT|CTRL", action = wezterm.action.QuickSelect },
	}

	config.enable_scroll_bar = true
	config.min_scroll_bar_height = "2cell"
	config.scrollback_lines = 30000 -- default 3500
	config.colors = {
		scrollbar_thumb = "#a0a0a0",
	}

	config.use_fancy_tab_bar = false
	config.tab_max_width = 32

	require("lua.tabline").setup(config)
	require("lua.tssh_domains").setup(config)
end
return M
