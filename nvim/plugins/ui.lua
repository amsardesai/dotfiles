-- UI Plugins: Theme, statusline, bufferline, visual enhancements

return {
	-- =============================================================================
	-- DEPENDENCIES (loaded when needed by other plugins)
	-- =============================================================================

	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- =============================================================================
	-- THEME (load immediately - no flicker)
	-- =============================================================================

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- =============================================================================
	-- SNACKS.NVIM (VeryLazy + keymaps)
	-- =============================================================================

	{
		"folke/snacks.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>bd",
				function()
					require("snacks").bufdelete()
				end,
				desc = "Delete buffer",
			},
			{
				"<leader>go",
				function()
					require("snacks").gitbrowse()
				end,
				desc = "Open in GitHub",
			},
			{
				"<leader>rn",
				function()
					require("snacks").rename.rename_file()
				end,
				desc = "Rename file",
			},
			{
				"]]",
				function()
					require("snacks").words.jump(1)
				end,
				desc = "Next reference",
			},
			{
				"[[",
				function()
					require("snacks").words.jump(-1)
				end,
				desc = "Prev reference",
			},
			{
				"<leader>z",
				function()
					if not _G.terminal_drawers then
						_G.terminal_drawers = dofile(vim.fn.stdpath("config") .. "/nvim/util/terminal_drawers.lua")
					end
					_G.terminal_drawers.toggle_primary()
				end,
				mode = { "n", "v", "t" },
				desc = "Toggle primary terminal",
			},
			{
				"<leader>x",
				function()
					if not _G.terminal_drawers then
						_G.terminal_drawers = dofile(vim.fn.stdpath("config") .. "/nvim/util/terminal_drawers.lua")
					end
					_G.terminal_drawers.toggle_secondary()
				end,
				mode = { "n", "v", "t" },
				desc = "Toggle secondary terminal",
			},
			{
				"<leader>q",
				function()
					if not _G.terminal_drawers then
						_G.terminal_drawers = dofile(vim.fn.stdpath("config") .. "/nvim/util/terminal_drawers.lua")
					end
					_G.terminal_drawers.close_all_terminal_windows()
				end,
				mode = { "n", "v", "t" },
				desc = "Close all terminal windows",
			},
			{
				"<leader>Q",
				function()
					if not _G.terminal_drawers then
						_G.terminal_drawers = dofile(vim.fn.stdpath("config") .. "/nvim/util/terminal_drawers.lua")
					end
					_G.terminal_drawers.close_all()
				end,
				mode = { "n", "v", "t" },
				desc = "Kill all terminals",
			},
		},
		opts = {
			bufdelete = { enabled = true },
			bigfile = { enabled = true },
			quickfile = { enabled = true },
			notifier = { enabled = true, timeout = 3000 },
			rename = { enabled = true },
			words = { enabled = true },
			gitbrowse = { enabled = true },
			input = { enabled = true },
			scope = { enabled = true },
			scroll = {
				enabled = true,
				animate = { duration = { step = 15, total = 100 } },
				animate_repeat = { duration = { step = 15, total = 50 } },
			},
			indent = {
				enabled = true,
				-- NOTE: Use box-drawing vertical line (U+2502), NOT regular pipe (|)
				char = "│",
				scope = { char = "│" },
				animate = { duration = { step = 10, total = 250 } },
			},
			dashboard = { enabled = false },
			terminal = {
				enabled = true,
				win = { position = "bottom", height = 0.3 },
			},
		},
	},

	-- =============================================================================
	-- LUALINE (VeryLazy)
	-- =============================================================================

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			options = { theme = "tokyonight" },
			sections = {
				lualine_x = { "encoding", "fileformat", "filetype", "lsp_status" },
			},
		},
	},

	-- =============================================================================
	-- BUFFERLINE (VeryLazy - load early for consistent tab bar)
	-- =============================================================================

	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy", -- Load early so tab bar is always visible
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				show_tab_indicators = true,
				separator_style = "slant",
				color_icons = false,
				hover = { enabled = true, delay = 50, reveal = { "close" } },
				offsets = { filetype = "NvimTree", text = "File Explorer", separator = true },
			},
		},
	},

	-- =============================================================================
	-- GITSIGNS (BufReadPre in git repos)
	-- =============================================================================

	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		cond = function()
			-- Only load if in a git repo
			local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
			return git_dir ~= ""
		end,
		keys = {
			{ "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
			{ ")", "<cmd>Gitsigns next_hunk<cr>", desc = "Next git hunk" },
			{ "(", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev git hunk" },
		},
		opts = {
			current_line_blame = true,
			current_line_blame_opts = { ignore_whitespace = true },
		},
	},

	-- =============================================================================
	-- SCROLLBAR (VeryLazy)
	-- =============================================================================

	{
		"petertriho/nvim-scrollbar",
		event = "VeryLazy",
		opts = {},
	},
}
