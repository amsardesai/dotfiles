-- Neovim Entry Point
-- Bootstraps lazy.nvim, loads plugins, then sources shared config

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before lazy (required by lazy.nvim)
vim.g.mapleader = ","
vim.g.maplocalleader = ";"

-- Config directory path
local config_dir = vim.fn.stdpath("config")
package.path = table.concat({
	config_dir .. "/?.lua",
	config_dir .. "/?/init.lua",
	package.path,
}, ";")

-- Load plugins via lazy.nvim
require("lazy").setup(require("plugins"), {
	-- Plugin installation directory
	root = vim.fn.stdpath("data") .. "/lazy",
	-- Don't notify on config changes
	change_detection = { notify = false },
	-- UI customization
	ui = {
		keys = {
			["<esc>"] = function(self)
				self:close()
			end,
		},
	},
	-- Performance optimizations
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Load shared vim/nvim configuration (VimScript)
vim.cmd("source " .. config_dir .. "/vimconfig/main.vim")

-- Load Neovim-specific Lua configuration
require("config.options")
require("config.keymaps")
