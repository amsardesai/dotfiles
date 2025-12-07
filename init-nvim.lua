-- Neovim Entry Point
-- Bootstraps lazy.nvim, loads plugins, then sources shared config

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    lazyrepo, lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Add nvimconfig to Lua path (it's symlinked to ~/.config/nvim/nvimconfig)
-- The pattern uses ? for directory name and ?.lua for file, so nvimconfig.plugins -> nvimconfig/plugins.lua
local config_path = vim.fn.stdpath("config")
package.path = config_path .. "/nvimconfig/?.lua;" .. config_path .. "/?.lua;" .. package.path

-- Set leader keys before lazy (required by lazy.nvim)
vim.g.mapleader = ","
vim.g.maplocalleader = ";"

-- Load plugins via lazy.nvim
-- Pass the plugin specs directly (lazy.nvim's module loader expects lua/ subdir)
require("lazy").setup(require("plugins"), {
  -- Plugin installation directory
  root = vim.fn.stdpath("data") .. "/lazy",
  -- Don't notify on config changes
  change_detection = { notify = false },
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
vim.cmd('source ~/.dotfiles/vimconfig/main.vim')

-- Load Neovim-specific Lua configuration
require('nvimconfig.main')
