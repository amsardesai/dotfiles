-- Editor Plugins: File navigation, editing, search

-- Helper: get nvim config directory path
local function get_config_dir()
	return vim.fn.stdpath("config") .. "/nvim"
end

-- Helper: toggle zoom current window to fullscreen float
local function toggle_zoom()
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
	-- NVIM-TREE (on keymap/command)
	-- =============================================================================

	{
		"nvim-tree/nvim-tree.lua",
		cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen", "NvimTreeClose" },
		-- Load when opening a directory (e.g., `nvim .`)
		init = function()
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function(data)
					-- Check if argument is a directory
					if vim.fn.isdirectory(data.file) == 1 then
						-- Load nvim-tree and open it
						require("lazy").load({ plugins = { "nvim-tree.lua" } })
						require("nvim-tree.api").tree.open()
						-- Open fzf file picker on top
						vim.schedule(function()
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
								})
							else
								fzf.files()
							end
						end)
					end
				end,
			})
		end,
		keys = {
			{
				"<leader>m",
				function()
					require("nvim-tree.api").tree.toggle()
					vim.cmd.wincmd("w")
				end,
				mode = { "n", "v", "t" },
				desc = "Toggle NvimTree",
			},
			{ "<leader>n", "<cmd>NvimTreeFindFile<cr>", mode = { "n", "v", "t" }, desc = "Find file in NvimTree" },
			{
				"<leader>b",
				function()
					require("nvim-tree.api").tree.open()
					vim.cmd.wincmd("w")
				end,
				desc = "Open NvimTree",
			},
		},
		config = function()
			require("nvim-tree").setup({
				view = { width = 30 },
				renderer = {
					add_trailing = true,
					group_empty = true,
					highlight_modified = "name",
					icons = { show = { hidden = true } },
				},
				on_attach = function(bufnr)
					local api = require("nvim-tree.api")
					api.config.mappings.default_on_attach(bufnr)
					-- Shift+Arrow navigation (matches global mappings)
					local opts = { buffer = bufnr, noremap = true, silent = true }
					vim.keymap.set("n", "<S-Up>", "<C-w><Up>", opts)
					vim.keymap.set("n", "<S-Down>", "<C-w><Down>", opts)
					vim.keymap.set("n", "<S-Left>", "<C-w><Left>", opts)
					vim.keymap.set("n", "<S-Right>", "<C-w><Right>", opts)
				end,
			})

			-- Integrate with snacks.nvim rename (notify LSP of file renames)
			local prev_rename = { new_name = "", old_name = "" }
			vim.api.nvim_create_autocmd("User", {
				pattern = "NvimTreeSetup",
				callback = function()
					local api = require("nvim-tree.api")
					api.events.subscribe(api.events.Event.NodeRenamed, function(data)
						if prev_rename.new_name ~= data.new_name or prev_rename.old_name ~= data.old_name then
							prev_rename = data
							-- Only call snacks if it's loaded
							local ok, snacks = pcall(require, "snacks")
							if ok then
								snacks.rename.on_rename_file(data.old_name, data.new_name)
							end
						end
					end)
				end,
			})
		end,
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
			{ "<C-o>", function() require("fzf-lua").live_grep() end, mode = { "n", "i" }, desc = "Live grep" },
			{ "<C-o>", function() require("fzf-lua").grep_visual() end, mode = "v", desc = "Grep visual selection" },
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
			{ "<leader>lk", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
			{ "<leader>lj", function() require("fzf-lua").grep_cword() end, desc = "Grep word under cursor" },
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
			{ "<C-S-CR>", function() toggle_zoom() end, mode = { "n", "v", "t" }, desc = "Toggle window zoom" },
			{ "<S-CR>", function() toggle_zoom() end, mode = { "n", "v" }, desc = "Toggle window zoom" },
		},
	},

	-- =============================================================================
	-- FLASH.NVIM (replaces vim-sneak)
	-- =============================================================================

	{
		"folke/flash.nvim",
		keys = {
			{ "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash jump" },
			{ "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash treesitter" },
			{ "r", function() require("flash").remote() end, mode = "o", desc = "Remote flash" },
			{ "R", function() require("flash").treesitter_search() end, mode = { "o", "x" }, desc = "Treesitter search" },
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
			{ "<leader>c", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment" },
			{ "<leader>c", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", mode = "v", desc = "Toggle comment" },
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
}
