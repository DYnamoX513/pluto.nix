local wezterm = require("wezterm")

-- Darwin ~/Library/Application Support/wezterm/plugins
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
-- Need manually update (git pull)

local M = {}
function M.setup(config)
	tabline.setup({
		options = {
			theme = config.color_scheme,
			-- section_separators = "",
			-- component_separators = "",
			-- tab_separators = {
			-- 	left = "",
			-- 	right = "",
			-- },
			section_separators = {
				-- left = " ",
				-- right = " ",
				left = wezterm.nerdfonts.ple_right_half_circle_thick,
				right = wezterm.nerdfonts.ple_left_half_circle_thick,
			},
			component_separators = {
				-- left = wezterm.nerdfonts.ple_right_half_circle_thin,
				-- right = wezterm.nerdfonts.ple_left_half_circle_thin,
				left = "|",
				right = "|",
			},
			tab_separators = {
				-- left = " ",
				-- right = " ",
				left = wezterm.nerdfonts.ple_right_half_circle_thick,
				right = wezterm.nerdfonts.ple_left_half_circle_thick,
			},
		},
		sections = {
			-- tab_active = {
			-- 	"index",
			-- 	{ "cwd", max_length = 10, padding = { left = 0, right = 1 } },
			-- 	{ "zoomed", padding = 0 },
			-- },
			tabline_y = {
				"datetime",
				--[[ "battery" ]]
			},
			tabline_z = {
				--[[ "hostname" ]]
			},
		},
	})
end
return M
