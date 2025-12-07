-- Neovim Global Keymaps
-- All keybindings that aren't tied to specific plugins

-- =============================================================================
-- GENERAL
-- =============================================================================

-- Disable Ex mode
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })
vim.keymap.set("n", "gQ", "<nop>", { desc = "Disable Ex mode" })

-- Escape to clear search highlight
vim.keymap.set("n", "<CR>", "<cmd>noh<cr><cr>", { silent = true, desc = "Clear search highlight" })

-- Page movement with _ and +
vim.keymap.set("n", "_", "<C-b>", { desc = "Page up" })
vim.keymap.set("n", "+", "<C-f>", { desc = "Page down" })
vim.keymap.set("v", "_", "<C-b>", { desc = "Page up" })
vim.keymap.set("v", "+", "<C-f>", { desc = "Page down" })

-- Ctrl-Backspace to delete word
vim.keymap.set("i", "<C-BS>", "<C-W>", { desc = "Delete word" })

-- Fix PageUp/PageDown (n, v modes + insert mode variant)
vim.keymap.set({ "n", "v" }, "<PageUp>", "<C-U>", { desc = "Half page up" })
vim.keymap.set({ "n", "v" }, "<PageDown>", "<C-D>", { desc = "Half page down" })
vim.keymap.set("i", "<PageUp>", "<C-O><C-U>", { desc = "Half page up" })
vim.keymap.set("i", "<PageDown>", "<C-O><C-D>", { desc = "Half page down" })

-- =============================================================================
-- COMMANDS
-- =============================================================================

vim.api.nvim_create_user_command("W", "write", { desc = "Write (alias for :w)" })
vim.api.nvim_create_user_command("Q", "quit", { desc = "Quit (alias for :q)" })

-- =============================================================================
-- BUFFER NAVIGATION
-- =============================================================================

-- F13/F14 for terminal Option-Shift-[ and Option-Shift-]
vim.keymap.set("n", "<F13>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<F14>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Leader buffer commands
vim.keymap.set("n", "<Leader>,", "<C-^>", { desc = "Alternate buffer" })
vim.keymap.set("n", "<Leader>]", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<Leader>[", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Leader>\\", "<cmd>bprevious<cr><cmd>bdelete #<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<Leader>|", "<cmd>bprevious<cr><cmd>bdelete! #<cr>", { desc = "Force delete buffer" })
vim.keymap.set("n", "<Leader>ls", "<cmd>buffers<cr>", { desc = "List buffers" })
vim.keymap.set("n", "<Leader>v", "<cmd>vsplit<cr>", { desc = "Vertical split" })

-- =============================================================================
-- PANE SWITCHING
-- =============================================================================

-- Shift+Arrow to switch panes (normal, insert, visual modes)
vim.keymap.set("n", "<S-Up>", "<C-w><Up>", { desc = "Move to pane above" })
vim.keymap.set("n", "<S-Down>", "<C-w><Down>", { desc = "Move to pane below" })
vim.keymap.set("n", "<S-Left>", "<C-w><Left>", { desc = "Move to left pane" })
vim.keymap.set("n", "<S-Right>", "<C-w><Right>", { desc = "Move to right pane" })
vim.keymap.set("i", "<S-Up>", "<C-w><Up>", { desc = "Move to pane above" })
vim.keymap.set("i", "<S-Down>", "<C-w><Down>", { desc = "Move to pane below" })
vim.keymap.set("i", "<S-Left>", "<C-w><Left>", { desc = "Move to left pane" })
vim.keymap.set("i", "<S-Right>", "<C-w><Right>", { desc = "Move to right pane" })
vim.keymap.set("v", "<S-Up>", "<C-w><Up>", { desc = "Move to pane above" })
vim.keymap.set("v", "<S-Down>", "<C-w><Down>", { desc = "Move to pane below" })
vim.keymap.set("v", "<S-Left>", "<C-w><Left>", { desc = "Move to left pane" })
vim.keymap.set("v", "<S-Right>", "<C-w><Right>", { desc = "Move to right pane" })

-- =============================================================================
-- UTILITY
-- =============================================================================

-- Close quickfix, preview, and location windows
vim.keymap.set(
	"n",
	"<Leader>q",
	"<cmd>cclose<cr><cmd>pclose<cr><cmd>lclose<cr>",
	{ desc = "Close quickfix/preview/location" }
)

-- Redraw screen
vim.keymap.set("n", "<Leader>rd", "<cmd>redraw!<cr>", { desc = "Redraw screen" })

-- Reload config (re-source all config files)
vim.keymap.set("n", "<Leader>r", function()
	local config_dir = vim.fn.stdpath("config")
	vim.cmd("source " .. config_dir .. "/vimconfig/main.vim")
	dofile(config_dir .. "/nvim/config/options.lua")
	dofile(config_dir .. "/nvim/config/keymaps.lua")
	vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload config" })

-- Fix whitespace (using mini.trailspace)
vim.keymap.set("n", "<Leader>fw", function()
	require("mini.trailspace").trim()
end, { desc = "Fix whitespace" })

-- =============================================================================
-- DIAGNOSTICS
-- =============================================================================

vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Next diagnostic" })

-- =============================================================================
-- FILETYPE
-- =============================================================================

-- Switch between .cc and .h files (C/C++)
vim.keymap.set("n", "<Leader>gh", function()
	local file = vim.fn.expand("%:p")
	if file:match("%.h$") then
		vim.cmd("edit " .. file:gsub("%.h$", ".cc"))
	elseif file:match("%.cc$") then
		vim.cmd("edit " .. file:gsub("%.cc$", ".h"))
	end
end, { desc = "Switch .cc/.h" })

-- Filetype detection autocmds
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "Rakefile", "Capfile", "Gemfile", ".autotest", ".irbrc", "*.treetop", "*.tt" },
	callback = function()
		vim.bo.filetype = "ruby"
	end,
	desc = "Set Ruby filetype",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { ".jshintrc", ".eslintrc" },
	callback = function()
		vim.bo.filetype = "json"
	end,
	desc = "Set JSON filetype",
})

-- =============================================================================
-- TERMINAL
-- =============================================================================

-- Better escaping from terminal mode
vim.keymap.set("t", ";;q", "<C-\\><C-n><cmd>bd!<cr>", { desc = "Close terminal" })
vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Pane navigation from terminal
vim.keymap.set("t", "<S-Left>", "<C-\\><C-n><C-w><Left>", { desc = "Move to left pane" })
vim.keymap.set("t", "<S-Up>", "<C-\\><C-n><C-w><Up>", { desc = "Move to pane above" })
vim.keymap.set("t", "<S-Down>", "<C-\\><C-n><C-w><Down>", { desc = "Move to pane below" })
vim.keymap.set("t", "<S-Right>", "<C-\\><C-n><C-w><Right>", { desc = "Move to right pane" })
vim.keymap.set("t", "<C-w><Left>", "<C-\\><C-n><C-w><Left>", { desc = "Move to left pane" })
vim.keymap.set("t", "<C-w><Up>", "<C-\\><C-n><C-w><Up>", { desc = "Move to pane above" })
vim.keymap.set("t", "<C-w><Down>", "<C-\\><C-n><C-w><Down>", { desc = "Move to pane below" })
vim.keymap.set("t", "<C-w><Right>", "<C-\\><C-n><C-w><Right>", { desc = "Move to right pane" })
vim.keymap.set("t", "<C-w><C-w>", "<C-\\><C-n><C-w><C-w>", { desc = "Next pane" })

-- Terminal buffer navigation
vim.keymap.set("t", "<Leader>,", "<C-\\><C-n><C-^>", { desc = "Alternate buffer" })
vim.keymap.set("t", "<Leader>]", "<C-\\><C-n><cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("t", "<Leader>[", "<C-\\><C-n><cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set(
	"t",
	"<Leader>\\",
	"<C-\\><C-n><cmd>bprevious<cr><C-\\><C-n><cmd>bdelete #<cr>",
	{ desc = "Delete buffer" }
)
vim.keymap.set(
	"t",
	"<Leader>|",
	"<C-\\><C-n><cmd>bprevious<cr><C-\\><C-n><cmd>bdelete! #<cr>",
	{ desc = "Force delete buffer" }
)
vim.keymap.set("t", "<Leader>ls", "<C-\\><C-n><cmd>buffers<cr>", { desc = "List buffers" })

-- Terminal utility (reload config - exits terminal mode first)
vim.keymap.set("t", "<Leader>r", function()
	vim.cmd("stopinsert")
	local config_dir = vim.fn.stdpath("config")
	vim.cmd("source " .. config_dir .. "/vimconfig/main.vim")
	dofile(config_dir .. "/nvim/config/options.lua")
	dofile(config_dir .. "/nvim/config/keymaps.lua")
	vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload config" })
vim.keymap.set("t", "<Leader>rd", "<C-\\><C-n><cmd>redraw!<cr>", { desc = "Redraw screen" })

-- Auto-insert on terminal enter, normal on leave
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	pattern = "term://*",
	command = "startinsert",
	desc = "Auto-insert in terminal",
})

vim.api.nvim_create_autocmd("BufLeave", {
	pattern = "term://*",
	command = "stopinsert",
	desc = "Stop insert on terminal leave",
})

-- =============================================================================
-- CONTEXT MENU
-- =============================================================================

local config_dir = vim.fn.stdpath("config") .. "/nvim"
local context_menu = dofile(config_dir .. "/util/context_menu.lua")
vim.keymap.set({ "n", "v" }, "<RightMouse>", context_menu.show, { desc = "Context menu" })

-- =============================================================================
-- LEGACY VIMSCRIPT
-- =============================================================================

-- BehaveZZ (calls VimScript function from helpers/behave_zz.vim)
vim.keymap.set("n", "ZZ", "<cmd>call BehaveZZ()<cr>", { desc = "BehaveZZ" })
