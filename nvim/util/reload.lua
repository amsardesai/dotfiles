-- Reload Neovim configuration modules without duplicating augroups/autocmds.

local M = {}

local modules_to_reload = {
	"config.options",
	"config.keymaps",
}

function M.reload()
	local config_dir = vim.fn.stdpath("config")

	vim.cmd("source " .. config_dir .. "/vimconfig/main.vim")

	for _, module in ipairs(modules_to_reload) do
		package.loaded[module] = nil
	end

	require("config.options")
	require("config.keymaps")

	vim.notify("Config reloaded", vim.log.levels.INFO)
end

return M
