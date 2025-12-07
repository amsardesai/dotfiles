-- Neovim Global Settings
-- Plugin configurations are now in plugins.lua for proper lazy-loading

-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Prevent automatic window resizing when opening/closing splits
vim.o.equalalways = false

-- Buffer navigation: Option-Shift-[ and Option-Shift-] (sent as F13/F14 by terminal)
vim.keymap.set("n", "<F13>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<F14>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Diagnostic keybindings (global, not LSP-specific)
vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Next diagnostic" })

-- Context menu (lazy-loads fzf-lua on use via vim.ui.select)
local config_dir = vim.fn.stdpath("config") .. "/nvim"
local context_menu = dofile(config_dir .. "/context_menu.lua")
vim.keymap.set({ "n", "v" }, "<RightMouse>", context_menu.show, { desc = "Context menu" })
