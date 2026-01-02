-- Neovim Global Options
-- Settings for vim.g and vim.o

-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- =============================================================================
-- RPC SERVER (for WezTerm file path clicking)
-- =============================================================================

-- Start server on pane-specific socket so multiple Neovim instances don't conflict
-- WezTerm click handler uses pane:pane_id() to find the correct socket
local pane_id = vim.env.WEZTERM_PANE
local socket_path
if pane_id then
	socket_path = vim.fn.expand("~/.cache/nvim/server-" .. pane_id .. ".sock")
else
	-- Fallback for non-WezTerm terminals
	socket_path = vim.fn.expand("~/.cache/nvim/server.sock")
end
vim.fn.mkdir(vim.fn.expand("~/.cache/nvim"), "p")
-- Remove stale socket and start fresh
pcall(vim.fn.delete, socket_path)
pcall(vim.fn.serverstart, socket_path)

-- Prevent automatic window resizing when opening/closing splits
vim.o.equalalways = false

-- =============================================================================
-- TERMINAL & GUI
-- =============================================================================

-- Faster update time for git signs and other plugins
vim.o.updatetime = 200

-- Enable mouse move events (required for some plugins)
vim.o.mousemoveevent = true

-- Enable 24-bit RGB colors in terminal
vim.o.termguicolors = true

-- Cursor shape per mode (blink timing controlled by terminal)
vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20"

-- =============================================================================
-- DISPLAY
-- =============================================================================

-- Global border for all floating windows (LSP hover, diagnostics, etc.)
vim.o.winborder = "rounded"

-- Indent wrapped lines to match start of line
vim.o.breakindent = true
vim.o.showbreak = ".."

-- Conceal level for JSON etc
vim.o.conceallevel = 2

-- =============================================================================
-- FILETYPES
-- =============================================================================

-- LaTeX filetype detection
vim.g.tex_flavor = "latex"

-- =============================================================================
-- CURSOR SHAPE
-- =============================================================================

-- Cursor shape escape sequences for terminals with incomplete terminfo (e.g., WezTerm)
-- Matches guicursor: n-v-c=block, i-ci-ve=bar, r-cr-o=underline
local function set_cursor_shape(shape)
	io.write(string.format("\27[%d q", shape))
	io.flush()
end

local cursor_group = vim.api.nvim_create_augroup("TerminalCursorShape", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
	group = cursor_group,
	pattern = "*",
	callback = function()
		local mode = vim.fn.mode()
		if mode:match("^i") then
			-- Insert modes: i, ic, ix (guicursor: i-ci-ve)
			set_cursor_shape(5) -- blinking bar
		elseif mode:match("^R") or mode:match("^no") then
			-- Replace: R, Rc, Rv, etc. + Operator-pending: no, nov, noV (guicursor: r-cr-o)
			set_cursor_shape(3) -- blinking underline
		else
			-- Normal, visual, select, command, etc. (guicursor: n-v-c)
			set_cursor_shape(1) -- blinking block
		end
	end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	group = cursor_group,
	callback = function()
		set_cursor_shape(0)
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = cursor_group,
	callback = function()
		set_cursor_shape(1)
	end,
})

-- =============================================================================
-- TERMINAL PERFORMANCE
-- =============================================================================

-- Aggressive scrollback limit for terminal buffers (reduces memory/rendering overhead)
-- Default is 10000, but this causes severe slowdowns at 12k+ lines
-- See: https://github.com/neovim/neovim/issues/11090
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("TerminalPerformance", { clear = true }),
	callback = function()
		-- Scrollback: 1000 lines (aggressive optimization for Claude Code output)
		vim.opt_local.scrollback = 1000

		-- Disable expensive visual features
		vim.opt_local.signcolumn = "no"
		vim.opt_local.foldcolumn = "0"
		vim.opt_local.cursorline = false
		vim.opt_local.cursorcolumn = false
		vim.opt_local.spell = false
		vim.opt_local.list = false
	end,
})
