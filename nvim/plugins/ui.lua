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
					if not _G.bottom_drawers then
						_G.bottom_drawers = dofile(vim.fn.stdpath("config") .. "/util/bottom_drawers.lua")
					end
					_G.bottom_drawers.toggle_primary()
				end,
				mode = { "n", "v", "t" },
				desc = "Toggle Terminal Z",
			},
			{
				"<leader>x",
				function()
					if not _G.bottom_drawers then
						_G.bottom_drawers = dofile(vim.fn.stdpath("config") .. "/util/bottom_drawers.lua")
					end
					_G.bottom_drawers.toggle_secondary()
				end,
				mode = { "n", "v", "t" },
				desc = "Toggle Terminal X",
			},
			{
				"<leader>t",
				function()
					if not _G.bottom_drawers then
						_G.bottom_drawers = dofile(vim.fn.stdpath("config") .. "/util/bottom_drawers.lua")
					end
					_G.bottom_drawers.toggle_trouble()
				end,
				mode = { "n", "v" },
				desc = "Toggle Diagnostics",
			},
			{
				"<leader>q",
				function()
					if not _G.bottom_drawers then
						_G.bottom_drawers = dofile(vim.fn.stdpath("config") .. "/util/bottom_drawers.lua")
					end
					_G.bottom_drawers.close_all_drawer_windows()
				end,
				mode = { "n", "v", "t" },
				desc = "Close all drawer windows",
			},
			{
				"<leader>Q",
				function()
					if not _G.bottom_drawers then
						_G.bottom_drawers = dofile(vim.fn.stdpath("config") .. "/util/bottom_drawers.lua")
					end
					_G.bottom_drawers.close_all()
				end,
				mode = { "n", "v", "t" },
				desc = "Kill all terminals",
			},
			{
				"<leader>gg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>S",
				function()
					require("snacks").scratch()
				end,
				desc = "Scratch buffer",
			},
			{
				"<leader>Sb",
				function()
					require("snacks").scratch.select()
				end,
				desc = "Select scratch buffer",
			},
		},
		opts = {
			bufdelete = { enabled = true },
			bigfile = { enabled = true },
			quickfile = { enabled = true },
			notifier = { enabled = true, timeout = 5000 },
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
			lazygit = { enabled = true },
			scratch = { enabled = true },
			dim = { enabled = true },
			image = { enabled = true },
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
				lualine_b = {
					{
						"branch",
						fmt = function(name)
							local max_len = 20
							if #name > max_len then
								return name:sub(1, max_len - 1) .. "…"
							end
							return name
						end,
					},
					"diff",
					"diagnostics",
				},
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
		dependencies = { "nvim-tree/nvim-web-devicons", "folke/snacks.nvim" },
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				show_tab_indicators = true,
				separator_style = "slant",
				color_icons = false,
				hover = { enabled = true, delay = 50, reveal = { "close" } },
				offsets = { { filetype = "neo-tree", text = "File Explorer", separator = true } },
				close_command = function(bufnr)
					require("snacks").bufdelete({ buf = bufnr })
				end,
				right_mouse_command = function(bufnr)
					require("snacks").bufdelete({ buf = bufnr })
				end,
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
	-- SCROLLBAR
	-- =============================================================================

	{
		"kevinhwang91/nvim-hlslens",
		event = "BufReadPost",
		opts = {
			nearest_only = true, -- Only show lens for nearest match
		},
		keys = {
			{
				"n",
				[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
				desc = "Next match",
			},
			{
				"N",
				[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
				desc = "Prev match",
			},
			{ "*", [[*<Cmd>lua require('hlslens').start()<CR>]], desc = "Search word forward" },
			{ "#", [[#<Cmd>lua require('hlslens').start()<CR>]], desc = "Search word backward" },
			{ "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], desc = "Search word forward (partial)" },
			{ "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], desc = "Search word backward (partial)" },
		},
	},

	{
		"petertriho/nvim-scrollbar",
		event = "BufReadPost",
		dependencies = { "kevinhwang91/nvim-hlslens" },
		opts = {
			handle = { color = "#3b4261" },
			marks = {
				Search = { color = "#ff9e64" },
				Error = { color = "#db4b4b" },
				Warn = { color = "#e0af68" },
				Info = { color = "#0db9d7" },
				Hint = { color = "#1abc9c" },
				Misc = { color = "#9d7cd8" },
				GitAdd = { color = "#449dab" },
				GitChange = { color = "#6183bb" },
				GitDelete = { color = "#914c54" },
			},
			handlers = {
				cursor = true,
				diagnostic = true,
				gitsigns = true,
				search = true,
			},
		},
	},
}
