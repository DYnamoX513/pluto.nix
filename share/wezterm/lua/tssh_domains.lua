local wezterm = require("wezterm")

local M = {}

-- Below configures T-SSH domains

-- Parse ~/.ssh/config Hosts
local function parse_ssh_config()
	--
	local host_list = {}
	local config_path = os.getenv("HOME") .. "/.ssh/config"

	local file = io.open(config_path, "r")
	if not file then
		return host_list -- No config file, empty
	end

	for line in file:lines() do
		if line:sub(1, 5) == "Host " then
			local hosts = {}
			-- separate by spaces
			for host in line:gmatch("%S+") do
				table.insert(hosts, host)
			end
			-- Remove the first 'Host' string
			table.remove(hosts, 1)
			for _, host in ipairs(hosts) do
				table.insert(host_list, host)
			end
		end
	end

	file:close()
	return host_list
end

-- local function make_tssh_label_func(name)
-- 	return wezterm.format({
-- 		{ Foreground = { AnsiColor = "Blue" } },
-- 		{ Text = "TSSH " .. name },
-- 	})
-- end

-- Fix up the requested host and return the revised command
local function make_tssh_fixup_func(host)
	return function(cmd)
		cmd.args = {
			os.getenv("SHELL"),
			"-lc", -- login & non-interactive
			"tssh " .. host,
		}
		cmd.set_environment_variables = {
			SSH_AUTH_SOCK = os.getenv("SSH_AUTH_SOCK"), -- ssh-agent
		}
		return cmd
	end
end

-- Return table of name -> command & label
function M.compute_exec_domains()
	-- test tssh installation
	local success, stdout, stderr = wezterm.run_child_process({
		os.getenv("SHELL"),
		"-lc",
		"tssh -V",
	})
	local color
	local text
	if success then
		color = "Blue"
		text = stdout:gsub("^%s*(.-)%s*$", "%1")
	else
		-- cannot find tssh in PATH
		color = "Red"
		text = "tssh -V failed: " .. stderr
	end

	local label = wezterm.format({
		{ Foreground = { AnsiColor = color } },
		{ Text = text },
	})

	local exec_domains = {}
	for _, host in ipairs(parse_ssh_config()) do
		table.insert(exec_domains, wezterm.exec_domain("T-SSH:" .. host, make_tssh_fixup_func(host), label))
	end
	return exec_domains
end

-- Add T-SSH domains to exec_domains
function M.setup(config)
	if config.exec_domains == nil then
		config.exec_domains = {}
	end
	for k, v in pairs(M.compute_exec_domains()) do
		config.exec_domains[k] = v
	end
end

return M
