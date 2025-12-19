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

-- Page movement with _ and + (scroll window_height - 10 lines for easier scanning)
vim.keymap.set({ "n", "v" }, "_", function()
	local lines = math.max(1, vim.api.nvim_win_get_height(0) - 10)
	local ctrl_y = vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
	vim.api.nvim_feedkeys(lines .. ctrl_y, "n", false)
end, { desc = "Scroll up (page - 10 lines)" })

vim.keymap.set({ "n", "v" }, "+", function()
	local lines = math.max(1, vim.api.nvim_win_get_height(0) - 10)
	local ctrl_e = vim.api.nvim_replace_termcodes("<C-e>", true, true, true)
	vim.api.nvim_feedkeys(lines .. ctrl_e, "n", false)
end, { desc = "Scroll down (page - 10 lines)" })

-- Ctrl-Backspace to delete word
vim.keymap.set("i", "<C-BS>", "<C-W>", { desc = "Delete word" })

-- Fix PageUp/PageDown (n, v modes + insert mode variant)
vim.keymap.set({ "n", "v" }, "<PageUp>", "<C-U>", { desc = "Half page up" })
vim.keymap.set({ "n", "v" }, "<PageDown>", "<C-D>", { desc = "Half page down" })
vim.keymap.set("i", "<PageUp>", "<C-O><C-U>", { desc = "Half page up" })
vim.keymap.set("i", "<PageDown>", "<C-O><C-D>", { desc = "Half page down" })

-- Restart all LSP servers (except null-ls to avoid warning)
vim.keymap.set("n", "<leader>rl", function()
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name ~= "null-ls" then
			vim.cmd("LspRestart " .. client.name)
		end
	end
	vim.notify("LSP servers restarted", vim.log.levels.INFO)
end, { desc = "Restart LSP servers" })

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

-- Shift+Arrow and Option-Shift+Arrow to switch panes
for _, dir in ipairs({ "Up", "Down", "Left", "Right" }) do
	local desc = "Move to " .. (dir == "Up" and "pane above" or dir == "Down" and "pane below" or dir:lower() .. " pane")
	for _, mode in ipairs({ "n", "i", "v" }) do
		vim.keymap.set(mode, "<S-" .. dir .. ">", "<C-w><" .. dir .. ">", { desc = desc })
		vim.keymap.set(mode, "<M-S-" .. dir .. ">", "<C-w><" .. dir .. ">", { desc = desc })
	end
	-- Terminal mode needs to exit first
	local term_rhs = "<C-\\><C-n><C-w><" .. dir .. ">"
	vim.keymap.set("t", "<S-" .. dir .. ">", term_rhs, { desc = desc })
	vim.keymap.set("t", "<M-S-" .. dir .. ">", term_rhs, { desc = desc })
end

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

-- Terminal mouse: single click enters terminal mode, drag allows visual selection
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		-- Track click position to distinguish clicks from drags
		vim.keymap.set({ "n", "v" }, "<LeftMouse>", function()
			local mouse = vim.fn.getmousepos()
			vim.b.terminal_click_pos = { line = mouse.line, col = mouse.column }
			return "<LeftMouse>"
		end, { buffer = true, expr = true, desc = "Track terminal click position" })

		-- On release, enter terminal mode if it was a single click
		vim.keymap.set({ "n", "v" }, "<LeftRelease>", function()
			local mouse = vim.fn.getmousepos()
			local click_pos = vim.b.terminal_click_pos

			if click_pos and click_pos.line == mouse.line and click_pos.col == mouse.column then
				vim.schedule(function()
					vim.cmd("startinsert")
				end)
			end
			vim.b.terminal_click_pos = nil
		end, { buffer = true, desc = "Enter terminal mode on single click" })
	end,
	desc = "Terminal mouse click handling",
})

-- =============================================================================
-- CONTEXT MENU
-- =============================================================================

local config_dir = vim.fn.stdpath("config")
local context_menu = dofile(config_dir .. "/util/context_menu.lua")
vim.keymap.set({ "n", "v" }, "<RightMouse>", context_menu.show, { desc = "Context menu" })

-- =============================================================================
-- LEGACY VIMSCRIPT
-- =============================================================================

-- BehaveZZ (calls VimScript function from helpers/behave_zz.vim)
vim.keymap.set("n", "ZZ", "<cmd>call BehaveZZ()<cr>", { desc = "BehaveZZ" })
