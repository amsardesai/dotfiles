-- Neovim plugin configurations
-- Loaded from main.vim via luafile

local vim = vim ---@diagnostic disable-line: undefined-global

-- Get the directory of this file for relative imports
local current_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

local NvimTreeApi = require("nvim-tree.api")
local Snacks = require("snacks")
local context_menu = dofile(current_dir .. "/helpers/context_menu.lua")

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setup nvim-tree
require("nvim-tree").setup({
	view = {
		width = 30,
	},
	renderer = {
		add_trailing = true,
		group_empty = true,
		highlight_modified = "name",
		icons = {
			show = {
				hidden = true,
			},
		},
	},
})

-- Integrate snacks.nvim rename with nvim-tree
-- When files are renamed in nvim-tree, notify LSP to update imports/references
local prev_rename = { new_name = "", old_name = "" }
vim.api.nvim_create_autocmd("User", {
	pattern = "NvimTreeSetup",
	callback = function()
		local events = NvimTreeApi.events
		events.subscribe(events.Event.NodeRenamed, function(data)
			if prev_rename.new_name ~= data.new_name or prev_rename.old_name ~= data.old_name then
				prev_rename = data
				Snacks.rename.on_rename_file(data.old_name, data.new_name)
			end
		end)
	end,
})

require("lualine").setup({
	theme = "tokyonight",
	sections = {
		lualine_x = { "encoding", "fileformat", "filetype", "lsp_status" },
	},
})

require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = {
		ignore_whitespace = true,
	},
})

require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		show_tab_indicators = true,
		separator_style = "slant",
		color_icons = false,
		hover = {
			enabled = true,
			delay = 50,
			reveal = { "close" },
		},
		offsets = {
			filetype = "NvimTree",
			text = "File Explorer",
			separator = true,
		},
	},
})

-- fzf-lua setup
local fzf = require("fzf-lua")

fzf.setup({
	-- Profiles: fzf-native uses bat for fast previews, hide keeps fzf in background
	{ "fzf-native", "hide" },

	-- Use native fzf binary (significantly faster for 100k+ files)
	fzf_bin = "fzf",

	files = {
		-- Git repos: use git ls-files (instant, uses git's index)
		-- Non-git: fallback to fd
		cmd = "git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --strip-cwd-prefix --hidden --exclude .git --exclude node_modules --exclude build",
		-- Disable git status icons for speed in large repos
		git_icons = false,
	},
	grep = {
		cmd = "rg --column --line-number --no-heading --color=always --smart-case --hidden -g '!.git' -g '!node_modules' -g '!build'",
	},
	winopts = {
		backdrop = 30,
		height = 0.8,
		width = 0.8,
		preview = {
			horizontal = "right:50%",
			delay = 250,
		},
		files = {
			file_icon_padding = "",
		},
	},
	oldfiles = {
		include_current_session = true,
		-- Frecency note: fzf-lua's oldfiles is recency-only (most recently opened).
		-- For true frecency (frequency + recency), consider adding smart-open.nvim
	},
})

-- Replace telescope-ui-select for vim.ui.select
fzf.register_ui_select()

-- File cache for instant file picker (avoids running git ls-files each time)
local file_cache = nil
local cache_job = nil

local function refresh_file_cache()
	-- Cancel any in-progress refresh
	if cache_job then
		pcall(vim.fn.jobstop, cache_job)
	end

	cache_job = vim.fn.jobstart("git ls-files --cached --others --exclude-standard", {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data then
				file_cache = vim.tbl_filter(function(l)
					return l ~= ""
				end, data)
			end
		end,
		on_exit = function()
			cache_job = nil
		end,
	})
end

-- Warm cache on startup (slight delay to not block UI)
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.defer_fn(refresh_file_cache, 100)
	end,
})

-- Refresh on directory change
vim.api.nvim_create_autocmd("DirChanged", {
	callback = refresh_file_cache,
})

-- Refresh periodically (every 60s) for external changes
local cache_timer = vim.uv.new_timer()
cache_timer:start(60000, 60000, vim.schedule_wrap(refresh_file_cache))

-- Watch .git/HEAD (checkouts, branch switches) and .git/index (commits, staging)
local git_watchers = {}

local function setup_git_watchers()
	-- Clean up existing watchers
	for _, watcher in ipairs(git_watchers) do
		watcher:stop()
	end
	git_watchers = {}

	local cwd = vim.fn.getcwd()
	local git_entry = cwd .. "/.git"

	-- Check if .git exists
	local stat = vim.uv.fs_stat(git_entry)
	if not stat then
		return
	end

	local git_dir

	-- Handle worktrees: .git is a file containing "gitdir: /path/to/git/dir"
	if stat.type == "file" then
		local content = vim.fn.readfile(git_entry)[1] or ""
		local gitdir = content:match("gitdir: (.+)")
		if not gitdir then
			return
		end

		-- Resolve relative paths
		if not gitdir:match("^/") then
			gitdir = vim.fn.fnamemodify(cwd .. "/" .. gitdir, ":p")
		end
		git_dir = gitdir:gsub("/$", "") .. "/"
	else
		git_dir = git_entry .. "/"
	end

	local debounce_timer = nil

	local function debounced_refresh()
		if debounce_timer then
			debounce_timer:stop()
		end
		debounce_timer = vim.defer_fn(refresh_file_cache, 200)
	end

	-- Watch HEAD and index
	for _, file in ipairs({ "HEAD", "index" }) do
		local filepath = git_dir .. file
		if vim.uv.fs_stat(filepath) then
			local watcher = vim.uv.new_fs_event()
			watcher:start(filepath, {}, vim.schedule_wrap(debounced_refresh))
			table.insert(git_watchers, watcher)
		end
	end
end

-- Setup git watchers on startup and directory change
vim.api.nvim_create_autocmd("VimEnter", {
	callback = setup_git_watchers,
})

vim.api.nvim_create_autocmd("DirChanged", {
	callback = setup_git_watchers,
})

-- Cached file picker
local function cached_files()
	if file_cache and #file_cache > 0 then
		fzf.fzf_exec(file_cache, {
			prompt = "Files❯ ",
			previewer = "builtin",
			actions = fzf.defaults.actions.files,
			file_icons = true,
			color_icons = true,
		})
	else
		-- Fallback if cache not ready
		fzf.files()
	end
end

-- Manual cache refresh
local function force_refresh_cache()
	file_cache = nil
	refresh_file_cache()
	vim.notify("File cache refreshing...", vim.log.levels.INFO)
end

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"comment",
		"css",
		"dockerfile",
		"git_config",
		"git_rebase",
		"gitignore",
		"gitcommit",
		"go",
		"html",
		"jsdoc",
		"json",
		"lua",
		"markdown",
		"markdown_inline",
		"typescript",
		"tsx",
		"tsv",
		"vim",
		"vimdoc",
		"yaml",
	},
	highlight = {
		enable = true,
	},
})

require("scrollbar").setup()

-- LSP Lens - show references/implementations above functions and types
local SymbolKind = vim.lsp.protocol.SymbolKind
require("lsp-lens").setup({
	enable = true,
	include_declaration = false,
	-- Show on functions, methods, interfaces, classes, types
	target_symbol_kinds = {
		SymbolKind.Function,
		SymbolKind.Method,
		SymbolKind.Interface,
		SymbolKind.Class,
		SymbolKind.Struct,
		SymbolKind.TypeParameter,
	},
	wrapper_symbol_kinds = { SymbolKind.Class, SymbolKind.Struct, SymbolKind.Module },
	sections = {
		definition = false,
		references = function(count)
			return " " .. count
		end,
		implements = function(count)
			return " " .. count
		end,
		git_authors = function(latest_author, count)
			if count > 1 then
				return " " .. latest_author .. " +" .. (count - 1)
			end
			return " " .. latest_author
		end,
	},
})

-- Diagnostic keybindings (global, not LSP-specific)
vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Next diagnostic" })
vim.keymap.set("n", "gL", "<cmd>LspLensToggle<cr>", { desc = "Toggle LSP lens" })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = function(desc)
			return { buffer = event.buf, desc = desc }
		end

		-- LSP keybindings (buffer-local, only active when LSP is attached)
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts("Hover documentation"))
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts("Go to definition"))
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts("Go to declaration"))
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts("Go to implementation"))
		vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts("Go to type definition"))
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts("Find references"))
		vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts("Signature help"))
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts("Rename symbol"))
		vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts("Format document"))
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts("Code actions"))
		vim.keymap.set("n", "gh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, opts("Toggle inlay hints"))
	end,
})

-- Strike through deprecated variables
vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { strikethrough = true, fg = "#5c6370" })

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false,
	underline = true,
	severity_sort = false,
	float = true,
})

-- Auto-show diagnostics on cursor hold
vim.o.updatetime = 250
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false })
	end,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local default_setup = function(server)
	require("lspconfig")[server].setup({
		capabilities = capabilities,
	})
end
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"cssls",
		"docker_compose_language_service",
		"docker_language_server",
		"dockerls",
		"eslint",
		"html",
		"jsonls",
		"lua_ls",
		"pylsp",
		"terraformls",
		"vimls",
		"yamlls",
	},
	automatic_enable = true,
	handlers = { default_setup },
})

-- none-ls: Linters & Formatters via LSP
local null_ls = require("null-ls")

null_ls.setup({
	-- Debug mode to see what's happening
	debug = true,
	-- Explicitly list filetypes to attach to
	filetypes = {
		"css",
		"dockerfile",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"lua",
		"markdown",
		"sh",
		"terraform",
		"tf",
		"typescript",
		"typescriptreact",
		"yaml",
	},
	sources = {
		-- Linters (diagnostics)
		null_ls.builtins.diagnostics.hadolint,
		null_ls.builtins.diagnostics.shellcheck,
		null_ls.builtins.diagnostics.markdownlint.with({
			-- Disable line-length rule (MD013) - too noisy for most markdown
			extra_args = { "--disable", "MD013" },
		}),
		null_ls.builtins.diagnostics.yamllint,
		null_ls.builtins.diagnostics.actionlint,

		-- Terraform
		null_ls.builtins.diagnostics.tflint,
		null_ls.builtins.formatting.terraform_fmt,

		-- Formatters
		-- Prettier for all web files (fallback formatter)
		null_ls.builtins.formatting.prettier.with({
			filetypes = {
				"css",
				"html",
				"javascript",
				"javascriptreact",
				"json",
				"markdown",
				"typescript",
				"typescriptreact",
				"yaml",
			},
			-- Run even without a prettier config file
			condition = function()
				return true
			end,
		}),
		-- Biome for JS/TS/JSON (will take precedence if biome.json exists in project)
		null_ls.builtins.formatting.biome.with({
			filetypes = {
				"javascript",
				"javascriptreact",
				"json",
				"typescript",
				"typescriptreact",
			},
			condition = function(utils)
				return utils.root_has_file({ "biome.json", "biome.jsonc" })
			end,
		}),
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.shfmt,
	},
})

-- Explicitly register eslint_d sources (none-ls-extras)
null_ls.register(require("none-ls.diagnostics.eslint_d"))
null_ls.register(require("none-ls.formatting.eslint_d"))

-- Mason integration for auto-installing linters/formatters
require("mason-null-ls").setup({
	ensure_installed = {
		"actionlint",
		"biome",
		"eslint_d",
		"hadolint",
		"markdownlint",
		"prettier",
		"shellcheck",
		"shfmt",
		"stylua",
		"tflint",
		"yamllint",
	},
	automatic_installation = true,
	handlers = {},
})

-- Format on save (runs eslint --fix + prettier/biome via null-ls)
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = {
		"*.css",
		"*.html",
		"*.js",
		"*.json",
		"*.jsx",
		"*.lua",
		"*.md",
		"*.sh",
		"*.tf",
		"*.ts",
		"*.tsx",
		"*.yaml",
		"*.yml",
	},
	callback = function(args)
		vim.lsp.buf.format({
			bufnr = args.buf,
			filter = function(client)
				return client.name == "null-ls"
			end,
		})
	end,
})

-- TypeScript support via typescript-tools.nvim (direct tsserver communication)
-- This bypasses typescript-language-server and talks directly to tsserver
require("typescript-tools").setup({
	capabilities = capabilities,
	settings = {
		-- Spawn additional tsserver instance for diagnostics (better performance)
		separate_diagnostic_server = true,
		-- Memory limit (16GB)
		tsserver_max_memory = 16384,
		-- Auto-close JSX tags
		jsx_close_tag = {
			enable = true,
			filetypes = { "javascriptreact", "typescriptreact" },
		},
		-- Code lens disabled (using lensline.nvim instead)
		code_lens = "off",
		-- Inlay hints configuration
		tsserver_file_preferences = {
			includeInlayParameterNameHints = "all",
			includeInlayParameterNameHintsWhenArgumentMatchesName = false,
			includeInlayFunctionParameterTypeHints = true,
			includeInlayVariableTypeHints = true,
			includeInlayVariableTypeHintsWhenTypeMatchesName = false,
			includeInlayPropertyDeclarationTypeHints = true,
			includeInlayFunctionLikeReturnTypeHints = true,
			includeInlayEnumMemberValueHints = true,
		},
	},
})

local cmp = require("cmp")
cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
	},
	mapping = cmp.mapping.preset.insert({
		-- Enter key confirms completion item
		["<CR>"] = cmp.mapping.confirm({ select = false }),

		-- Ctrl + space triggers completion menu
		["<C-Space>"] = cmp.mapping.complete(),
	}),
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
})

-- Snacks.nvim - Collection of small QoL plugins
if not vim.g.snacks_setup_done then
	vim.g.snacks_setup_done = true
	Snacks.setup({
		-- Better buffer deletion (preserves window layout)
		bufdelete = { enabled = true },
		-- Optimizations for large files
		bigfile = { enabled = true },
		-- Quick file picker from recent files
		quickfile = { enabled = true },
		-- Notifications
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		-- Better LSP rename (shows preview)
		rename = { enabled = true },
		-- Highlight words under cursor
		words = { enabled = true },
		-- Git browse (open file in GitHub)
		gitbrowse = { enabled = true },
		-- Input UI improvement
		input = { enabled = true },
		-- Scope-based animations/dimming
		scope = {
			enabled = true,
		},
		-- Smooth scrolling
		scroll = {
			enabled = true,
			animate = {
				duration = { step = 15, total = 100 },
			},
			animate_repeat = {
				duration = { step = 15, total = 50 },
			},
		},
		-- Indent guides
		indent = {
			enabled = true,
			char = "│",
			scope = { char = "│" },
			animate = {
				duration = { step = 10, total = 250 },
			},
		},
		-- Dashboard (startup screen)
		dashboard = {
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 2, 2 } },
				{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
			},
		}, -- disable if you prefer empty buffer
		-- Terminal (replaces vimconfig/terminal.vim functions)
		terminal = {
			enabled = true,
			win = {
				position = "bottom",
				height = 0.3, -- 30% height (matches previous behavior)
			},
		},
	})
end

-- Snacks keybindings
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>go", function()
	Snacks.gitbrowse()
end, { desc = "Open in GitHub" })
vim.keymap.set("n", "<leader>rn", function()
	Snacks.rename.rename_file()
end, { desc = "Rename file" })
vim.keymap.set("n", "]]", function()
	Snacks.words.jump(1)
end, { desc = "Next reference" })
vim.keymap.set("n", "[[", function()
	Snacks.words.jump(-1)
end, { desc = "Prev reference" })

-- Snacks terminal keybindings

-- Bottom terminal (default shell)
local function toggleBottomTerminal()
	Snacks.terminal.toggle()
end

vim.keymap.set({ "n", "v" }, "<leader>z", toggleBottomTerminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<leader>z", toggleBottomTerminal, { desc = "Toggle terminal" })

-- Hide all terminals (preserves session)
vim.keymap.set({ "n", "v", "t" }, "<leader>x", function()
	for _, term in ipairs(Snacks.terminal.list()) do
		term:hide()
	end
end, { desc = "Hide all terminals" })
-- Kill all terminals (terminates session)
vim.keymap.set({ "n", "v", "t" }, "<leader>X", function()
	for _, term in ipairs(Snacks.terminal.list()) do
		term:close()
	end
end, { desc = "Kill all terminals" })

-- claudecode.nvim setup (editor context integration with Claude Code)
require("claudecode").setup({
	terminal = {
		split_side = "right",
		split_width_percentage = 0.40,
		provider = "snacks",
	},
})

-- Toggle Claude Code terminal (drawer behavior with editor context)
vim.keymap.set({ "n", "v" }, "<leader>a", ":ClaudeCode<CR>", { desc = "Toggle Claude Code" })
vim.keymap.set("t", "<leader>a", "<C-\\><C-n>:ClaudeCode<CR>", { desc = "Toggle Claude Code" })
-- Send visual selection to Claude
vim.keymap.set("v", "<leader>a", ":ClaudeCodeSend<CR>", { desc = "Send selection to Claude" })
-- Add current file to Claude context
vim.keymap.set("n", "<leader>sa", ":ClaudeCodeAdd<CR>", { desc = "Add file to Claude context" })

-- Fuzzy finder (fzf-lua)
-- Primary file picker (uses cached file list for speed)
vim.keymap.set({ "n", "i", "v", "t" }, "<C-p>", cached_files, { silent = true, desc = "Find files" })
vim.keymap.set({ "n", "i" }, "<C-o>", fzf.live_grep, { silent = true, desc = "Live grep" })
vim.keymap.set("v", "<C-o>", fzf.grep_visual, { silent = true, desc = "Grep visual selection" })
vim.keymap.set("n", "<leader>ll", cached_files, { silent = true, desc = "Find files" })
vim.keymap.set("n", "<leader>lr", force_refresh_cache, { silent = true, desc = "Refresh file cache" })
vim.keymap.set("n", "<leader>lk", fzf.live_grep, { silent = true, desc = "Live grep" })
vim.keymap.set("n", "<leader>lj", fzf.grep_cword, { silent = true, desc = "Grep word under cursor" })

-- Right-click context menu
local function showContextMenu()
	context_menu.show()
end
vim.keymap.set({ "n", "v" }, "<RightMouse>", showContextMenu, { desc = "Context menu" })

local function toggleNvimTree()
	NvimTreeApi.tree.toggle()
	vim.cmd.wincmd("w")
end

local function launchNvimTree()
	NvimTreeApi.tree.open()
	vim.cmd.wincmd("w")
end

-- NvimTree keybindings
vim.keymap.set("n", "<leader>m", toggleNvimTree, { silent = true, desc = "Toggle NvimTree" })
vim.keymap.set("n", "<leader>n", ":NvimTreeFindFile<CR>", { silent = true, desc = "Find file in NvimTree" })
vim.keymap.set("n", "<leader>b", launchNvimTree, { silent = true, desc = "Open NvimTree" })

-- Gitsigns keybindings
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { silent = true, desc = "Git blame line" })
vim.keymap.set("n", ")", ":Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
vim.keymap.set("n", "(", ":Gitsigns prev_hunk<CR>", { desc = "Prev git hunk" })

-- Image viewing in terminal (requires ImageMagick: brew install imagemagick)
require("image").setup({
	backend = "kitty", -- WezTerm supports kitty protocol (try "sixel" if issues)
	processor = "magick_cli", -- Use ImageMagick CLI
	integrations = {
		markdown = { enabled = false },
		neorg = { enabled = false },
		typst = { enabled = false },
		html = { enabled = false },
		css = { enabled = false },
	},
	max_height_window_percentage = 80,
	max_width_window_percentage = 80,
	hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.ico", "*.svg" },
})
