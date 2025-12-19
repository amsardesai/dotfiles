-- Editor Plugins: File navigation, editing, search

-- Helper: get nvim config directory path
local function get_config_dir()
	return vim.fn.stdpath("config")
end

-- Helper: perform the actual zoom operation
local function do_zoom()
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

-- Helper: toggle zoom current window to fullscreen float
local function toggle_zoom()
	-- Exit terminal mode first if we're in it
	if vim.fn.mode() == "t" then
		-- Send <C-\><C-n> to exit terminal mode, then schedule zoom
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
		vim.schedule(do_zoom)
	else
		do_zoom()
	end
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
			-- Set float title highlight (yellow background like git status)
			vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { fg = "#ffffff", bg = "#ca8a04", bold = true })

			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function(data)
					-- Determine if we should try to restore session:
					-- - nvim (no args) OR nvim . (directory arg)
					local argc = vim.fn.argc()
					local should_restore = argc == 0 or (argc == 1 and vim.fn.isdirectory(data.file) == 1)

					if not should_restore then
						return -- Opening specific file(s), don't restore session
					end

					-- Count buffers before restore
					local buffers_before = #vim.tbl_filter(function(b)
						return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
					end, vim.api.nvim_list_bufs())

					-- Try to restore session
					require("lazy").load({ plugins = { "persistence.nvim" } })
					require("persistence").load()

					-- Count buffers after restore
					local buffers_after = #vim.tbl_filter(function(b)
						return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
					end, vim.api.nvim_list_bufs())

					local session_restored = buffers_after > buffers_before

					-- Load neo-tree and show sidebar
					require("lazy").load({ plugins = { "neo-tree.nvim" } })
					vim.cmd("Neotree action=show")

					if session_restored then
						-- Session restored with buffers - focus the main window
						vim.defer_fn(function()
							vim.cmd("wincmd l")
						end, 50)
					else
						-- No session or empty session - show fzf picker
						vim.defer_fn(function()
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
				"<leader>s",
				"<cmd>Neotree float toggle git_status<cr>",
				mode = { "n", "v" },
				desc = "Git status (float)",
			},
			{
				"<leader>b",
				"<cmd>Neotree float toggle buffers<cr>",
				mode = { "n", "v" },
				desc = "Buffers (float)",
			},
		},
		opts = {
			sources = { "filesystem", "git_status", "buffers" },
			close_if_last_window = true,
			-- Popup settings for float windows
			popup_border_style = "rounded",
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
				window = {
					position = "float",
					popup = {
						size = { height = "40%", width = "30%" },
						position = { row = 1, col = 1 },
					},
				},
			},
			buffers = {
				window = {
					position = "float",
					popup = {
						size = { height = "40%", width = "30%" },
						position = { row = 1, col = 1 },
					},
				},
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
					-- zz centers cursor (neo-tree's z closes nodes, so zz would trigger that)
					["zz"] = function()
						vim.cmd("normal! zz")
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
					-- Get visual selection if in visual mode
					local query = nil
					local mode = vim.fn.mode()
					if mode == "v" or mode == "V" then
						vim.cmd('noau normal! "vy')
						query = vim.fn.getreg("v")
						query = query:gsub("\n", "")
					end

					local file_cache = dofile(get_config_dir() .. "/util/file_cache.lua")
					local fzf = require("fzf-lua")
					local files = file_cache.get()
					if files and #files > 0 then
						fzf.fzf_exec(files, {
							prompt = "Files> ",
							query = query,
							previewer = "builtin",
							actions = fzf.defaults.actions.files,
							file_icons = true,
							color_icons = true,
						})
					else
						vim.notify("File cache not ready, searching...", vim.log.levels.WARN)
						fzf.files({ query = query })
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

	-- =============================================================================
	-- AERIAL.NVIM (code outline)
	-- =============================================================================

	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{
				"<leader>d",
				"<cmd>AerialToggle!<cr>",
				desc = "Code outline (aerial)",
			},
		},
		opts = {
			backends = { "treesitter", "lsp" },
			default_direction = "float",
			float = {
				border = "rounded",
				relative = "editor",
				override = function(conf, source_winid)
					-- Position at top-left corner
					conf.anchor = "NW"
					conf.row = 1
					conf.col = 1
					conf.height = math.floor(vim.o.lines * 0.4)
					conf.width = math.floor(vim.o.columns * 0.3)
					return conf
				end,
			},
			-- Navigation keymaps when inside aerial
			on_attach = function(bufnr)
				vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
		},
	},

	-- =============================================================================
	-- GX.NVIM (URL opener)
	-- =============================================================================

	{
		"chrishrb/gx.nvim",
		keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
		cmd = { "Browse" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
	},

	-- =============================================================================
	-- PERSISTENCE.NVIM (session management)
	-- =============================================================================

	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- Load early for session tracking
		opts = {
			-- Only save buffers, not full window layout
			options = { "buffers", "curdir", "tabpages" },
		},
		init = function()
			-- :qa! should NOT save session
			vim.api.nvim_create_autocmd("QuitPre", {
				callback = function()
					if vim.v.cmdbang == 1 then
						require("persistence").stop()
					end
				end,
			})
		end,
	},
}
