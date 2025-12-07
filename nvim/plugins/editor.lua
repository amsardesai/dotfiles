-- Editor Plugins: File navigation, editing, search

-- Helper: get nvim config directory path
local function get_config_dir()
	return vim.fn.stdpath("config") .. "/nvim"
end

-- Helper: toggle zoom current window to fullscreen float
local function toggle_zoom()
	-- Exit terminal mode first if we're in it
	if vim.fn.mode() == "t" then
		vim.cmd("stopinsert")
	end

	local MiniMisc = require("mini.misc")
	MiniMisc.setup()
	MiniMisc.zoom(0, {
		width = vim.o.columns,
		height = vim.o.lines,
		row = 0,
		col = 0,
		border = "double",
		title_pos = "center",
	})
	local win = vim.api.nvim_get_current_win()
	vim.wo[win].winblend = 5
	vim.wo[win].winhighlight = "Normal:NormalFloat"
end

return {
	-- =============================================================================
	-- NEO-TREE (file explorer + git status)
	-- =============================================================================

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		cmd = "Neotree",
		-- Load when opening a directory (e.g., `nvim .`)
		init = function()
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function(data)
					-- Check if argument is a directory
					if vim.fn.isdirectory(data.file) == 1 then
						-- Load neo-tree and open it
						require("lazy").load({ plugins = { "neo-tree.nvim" } })
						vim.cmd("Neotree action=show")

						-- Open fzf file picker after UI settles
						vim.defer_fn(function()
							-- Move focus away from neo-tree to main area
							vim.cmd("wincmd l")

							require("lazy").load({ plugins = { "fzf-lua" } })
							local file_cache = dofile(get_config_dir() .. "/util/file_cache.lua")
							file_cache.setup()
							local files = file_cache.get()
							local fzf = require("fzf-lua")
							if files and #files > 0 then
								fzf.fzf_exec(files, {
									prompt = "Files> ",
									previewer = "builtin",
									actions = fzf.defaults.actions.files,
									file_icons = true,
									color_icons = true,
									winopts = { focusable = true },
								})
							else
								fzf.files({ winopts = { focusable = true } })
							end
						end, 100)
					end
				end,
			})
		end,
		keys = {
			{
				"<leader>m",
				function()
					vim.cmd("Neotree toggle action=show")
				end,
				mode = { "n", "v", "t" },
				desc = "Toggle file tree",
			},
			{
				"<leader>n",
				function()
					vim.cmd("Neotree reveal")
				end,
				mode = { "n", "v", "t" },
				desc = "Focus tree & reveal file",
			},
			{
				"<leader>b",
				function()
					vim.cmd("Neotree action=show")
				end,
				desc = "Show file tree",
			},
			{
				"<leader>g",
				function()
					vim.cmd("Neotree toggle source=git_status action=show")
				end,
				mode = { "n", "v" },
				desc = "Toggle git status",
			},
		},
		opts = {
			sources = { "filesystem", "git_status", "buffers" },
			close_if_last_window = true,
			filesystem = {
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				group_empty_dirs = true,
			},
			git_status = {
				window = { position = "left", width = 40 },
			},
			default_component_configs = {
				indent = {
					with_markers = true,
					indent_size = 2,
				},
				modified = {
					symbol = "●",
				},
				git_status = {
					symbols = {
						added = "✚",
						modified = "",
						deleted = "✖",
						renamed = "󰁕",
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
			},
			window = {
				width = 30,
				mappings = {
					-- Shift+Arrow navigation (matches global mappings)
					["<S-Up>"] = function()
						vim.cmd("wincmd k")
					end,
					["<S-Down>"] = function()
						vim.cmd("wincmd j")
					end,
					["<S-Left>"] = function()
						vim.cmd("wincmd h")
					end,
					["<S-Right>"] = function()
						vim.cmd("wincmd l")
					end,
				},
			},
			event_handlers = {
				-- Integrate with snacks.nvim rename (notify LSP of file renames)
				{
					event = "file_renamed",
					handler = function(args)
						local ok, snacks = pcall(require, "snacks")
						if ok then
							snacks.rename.on_rename_file(args.source, args.destination)
						end
					end,
				},
				{
					event = "file_moved",
					handler = function(args)
						local ok, snacks = pcall(require, "snacks")
						if ok then
							snacks.rename.on_rename_file(args.source, args.destination)
						end
					end,
				},
			},
		},
	},

	-- =============================================================================
	-- FZF-LUA (on keymap)
	-- =============================================================================

	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		dependencies = "nvim-tree/nvim-web-devicons",
		keys = {
			{
				"<C-p>",
				function()
					local file_cache = dofile(get_config_dir() .. "/util/file_cache.lua")
					local fzf = require("fzf-lua")
					local files = file_cache.get()
					if files and #files > 0 then
						fzf.fzf_exec(files, {
							prompt = "Files> ",
							previewer = "builtin",
							actions = fzf.defaults.actions.files,
							file_icons = true,
							color_icons = true,
						})
					else
						vim.notify("File cache not ready, searching...", vim.log.levels.WARN)
						fzf.files()
					end
				end,
				mode = { "n", "i", "v", "t" },
				desc = "Find files",
			},
			{
				"<C-o>",
				function()
					require("fzf-lua").live_grep()
				end,
				mode = { "n", "i" },
				desc = "Live grep",
			},
			{
				"<C-o>",
				function()
					require("fzf-lua").grep_visual()
				end,
				mode = "v",
				desc = "Grep visual selection",
			},
			{
				"<leader>ll",
				function()
					local file_cache = dofile(get_config_dir() .. "/util/file_cache.lua")
					local fzf = require("fzf-lua")
					local files = file_cache.get()
					if files and #files > 0 then
						fzf.fzf_exec(files, {
							prompt = "Files> ",
							previewer = "builtin",
							actions = fzf.defaults.actions.files,
							file_icons = true,
							color_icons = true,
						})
					else
						fzf.files()
					end
				end,
				desc = "Find files",
			},
			{
				"<leader>lr",
				function()
					local file_cache = dofile(get_config_dir() .. "/util/file_cache.lua")
					file_cache.force_refresh()
				end,
				desc = "Refresh file cache",
			},
			{
				"<leader>lk",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>lj",
				function()
					require("fzf-lua").grep_cword()
				end,
				desc = "Grep word under cursor",
			},
		},
		config = function()
			local fzf = require("fzf-lua")
			fzf.setup({
				{ "fzf-native", "hide" },
				fzf_bin = "fzf",
				previewers = { bat = { theme = "tokyonight_night" } },
				files = {
					cmd = "git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --strip-cwd-prefix --hidden --exclude .git --exclude node_modules --exclude build",
					git_icons = false,
				},
				grep = {
					cmd = "rg --column --line-number --no-heading --color=always --smart-case --hidden -g '!.git' -g '!node_modules' -g '!build'",
				},
				winopts = {
					backdrop = 30,
					height = 0.8,
					width = 0.8,
					preview = { horizontal = "right:50%", delay = 250 },
					files = { file_icon_padding = "" },
				},
				oldfiles = { include_current_session = true },
			})

			-- Register for vim.ui.select
			fzf.register_ui_select()

			-- Setup file cache
			local file_cache = dofile(get_config_dir() .. "/util/file_cache.lua")
			file_cache.setup()
		end,
	},

	-- =============================================================================
	-- MINI.MISC (only for zoom, load on keymap)
	-- =============================================================================

	{
		"echasnovski/mini.misc",
		keys = {
			{
				"<M-S-CR>",
				function()
					toggle_zoom()
				end,
				mode = { "n", "v", "i", "t" },
				desc = "Toggle window zoom",
			},
		},
	},

	-- =============================================================================
	-- FLASH.NVIM (replaces vim-sneak)
	-- =============================================================================

	{
		"folke/flash.nvim",
		keys = {
			{
				"s",
				function()
					require("flash").jump()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash jump",
			},
			{
				"S",
				function()
					require("flash").treesitter()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash treesitter",
			},
			{
				"r",
				function()
					require("flash").remote()
				end,
				mode = "o",
				desc = "Remote flash",
			},
			{
				"R",
				function()
					require("flash").treesitter_search()
				end,
				mode = { "o", "x" },
				desc = "Treesitter search",
			},
		},
		opts = {
			modes = {
				char = { enabled = false }, -- Don't override f/F/t/T
			},
		},
	},

	-- =============================================================================
	-- NVIM-SURROUND (replaces vim-surround, has built-in dot-repeat)
	-- =============================================================================

	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		opts = {}, -- Uses default keymaps: cs, ds, ys
	},

	-- =============================================================================
	-- COMMENT.NVIM (replaces nerdcommenter)
	-- =============================================================================

	{
		"numToStr/Comment.nvim",
		keys = {
			{
				"<leader>c",
				function()
					require("Comment.api").toggle.linewise.current()
				end,
				desc = "Toggle comment",
			},
			{
				"<leader>c",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
				mode = "v",
				desc = "Toggle comment",
			},
		},
		opts = {
			-- Disable default mappings, we use <leader>c
			mappings = { basic = false, extra = false },
		},
	},

	-- =============================================================================
	-- MINI.TRAILSPACE (replaces vim-trailing-whitespace)
	-- =============================================================================

	{
		"echasnovski/mini.trailspace",
		event = "BufReadPost",
		config = function()
			require("mini.trailspace").setup()
			-- Highlight trailing whitespace in red
			vim.api.nvim_set_hl(0, "MiniTrailspace", { bg = "#f38ba8" })
		end,
	},

	-- =============================================================================
	-- VIM-VISUAL-MULTI
	-- =============================================================================

	{
		"mg979/vim-visual-multi",
		branch = "master",
		keys = { "<C-n>" },
		init = function()
			vim.g.VM_maps = {
				["Select h"] = "",
				["Select l"] = "",
			}
		end,
	},

	-- =============================================================================
	-- VIM-SLEUTH (auto-detect indent)
	-- =============================================================================

	{ "tpope/vim-sleuth", event = "BufReadPre" },

	-- =============================================================================
	-- TROUBLE.NVIM (diagnostics drawer, managed by bottom_drawers.lua)
	-- =============================================================================

	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {
			auto_close = false,
			auto_preview = false,
			focus = true,
			win = {
				wo = {
					winbar = "", -- Disable default winbar, we set our own
				},
			},
			modes = {
				diagnostics = {
					mode = "diagnostics",
					preview = { type = "main", position = "right" },
				},
			},
		},
	},
}
