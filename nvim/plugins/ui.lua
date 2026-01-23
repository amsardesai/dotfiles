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
				"<leader>q",
				function()
					if not _G.bottom_drawers then
						_G.bottom_drawers = dofile(vim.fn.stdpath("config") .. "/util/bottom_drawers.lua")
					end
					-- Hide terminal windows (preserve buffers, don't kill processes)
					_G.bottom_drawers.hide_all()

					-- Close neo-tree sidebar (if open)
					pcall(vim.cmd, "Neotree close")

					-- Close Claude Code panel (only if open)
					local ok, terminal = pcall(require, "claudecode.terminal")
					if ok and terminal and terminal.get_active_terminal_bufnr then
						local bufnr = terminal.get_active_terminal_bufnr()
						if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
							-- Find window containing this buffer and close it
							for _, win in ipairs(vim.api.nvim_list_wins()) do
								if vim.api.nvim_win_get_buf(win) == bufnr then
									vim.api.nvim_win_close(win, false)
									break
								end
							end
						end
					end
				end,
				mode = { "n", "v", "t" },
				desc = "Hide all drawers",
			},
			{
				"<leader>Q",
				function()
					-- Close bottom drawer terminals (kills processes)
					if not _G.bottom_drawers then
						_G.bottom_drawers = dofile(vim.fn.stdpath("config") .. "/util/bottom_drawers.lua")
					end
					_G.bottom_drawers.close_all()

					-- Close neo-tree sidebar
					pcall(vim.cmd, "Neotree close")

					-- Kill claudecode.nvim terminal
					local ok, terminal = pcall(require, "claudecode.terminal")
					if ok and terminal then
						local bufnr = terminal.get_active_terminal_bufnr and terminal.get_active_terminal_bufnr()
						if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
							local channel = vim.bo[bufnr].channel
							if channel and channel > 0 then
								pcall(vim.fn.jobstop, channel)
							end
							pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
						end
					end

					-- Kill stray claude processes in current directory
					local cwd = vim.fn.getcwd()
					local handle = io.popen("pgrep -x claude 2>/dev/null")
					if handle then
						local pids = handle:read("*a")
						handle:close()
						for pid in pids:gmatch("%d+") do
							local lsof = io.popen("lsof -p " .. pid .. " 2>/dev/null | grep cwd | awk '{print $NF}'")
							if lsof then
								local proc_cwd = lsof:read("*a"):gsub("%s+$", "")
								lsof:close()
								if proc_cwd == cwd then
									os.execute("kill -9 " .. pid .. " 2>/dev/null")
								end
							end
						end
					end
				end,
				mode = { "n", "v", "t" },
				desc = "Kill all panels and Claude processes",
			},
			{
				"<leader>gg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>go",
				function()
					-- Get the commit hash that last modified the current line
					local line = vim.fn.line(".")
					local file = vim.fn.expand("%:p")
					local result = vim.fn.system(
						"git blame -L " .. line .. "," .. line .. " --porcelain " .. vim.fn.shellescape(file) .. " 2>/dev/null | head -1"
					)
					local commit = result:match("^(%x+)")

					if commit and commit ~= "0000000000000000000000000000000000000000" then
						require("snacks").gitbrowse({ what = "commit", commit = commit })
					else
						vim.notify("No commit found for this line (uncommitted change?)", vim.log.levels.WARN)
					end
				end,
				desc = "Open commit in GitHub",
			},
			{
				"<leader>gf",
				function()
					require("snacks").gitbrowse({ what = "file" })
				end,
				desc = "Open file in GitHub",
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
							-- Lazy-load and cache text utils (only reads file once)
							_G._text_utils = _G._text_utils
								or dofile(vim.fn.stdpath("config") .. "/util/text.lua")
							return _G._text_utils.truncate_middle(name, 20)
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
				custom_filter = function(buf_number)
					-- Exclude neo-tree buffers from bufferline
					local ft = vim.bo[buf_number].filetype
					if ft == "neo-tree" then
						return false
					end
					return true
				end,
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
