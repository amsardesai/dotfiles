-- Neovim Entry Point
-- Sources shared VimScript config, then loads Neovim-specific Lua config

-- Load shared vim/nvim configuration (VimScript)
vim.cmd('source ~/.dotfiles/vimconfig/main.vim')

-- Load Neovim-specific Lua configuration
require('nvimconfig.main')
