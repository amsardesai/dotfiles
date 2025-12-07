-- Neovim Global Keymaps
-- Keybindings that aren't tied to specific plugins

-- Buffer navigation: Option-Shift-[ and Option-Shift-] (sent as F13/F14 by terminal)
vim.keymap.set("n", "<F13>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<F14>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Diagnostic keybindings (global, not LSP-specific)
vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Next diagnostic" })

-- Context menu (lazy-loads fzf-lua on use via vim.ui.select)
local config_dir = vim.fn.stdpath("config") .. "/nvim"
local context_menu = dofile(config_dir .. "/util/context_menu.lua")
vim.keymap.set({ "n", "v" }, "<RightMouse>", context_menu.show, { desc = "Context menu" })
