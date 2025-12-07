-- Neovim plugin configurations
-- Loaded from main.vim via luafile

-- Add Mason bin to PATH so none-ls can find installed tools
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- Get the directory of this file for relative imports
local current_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

local NvimTreeApi = require("nvim-tree.api")
local Snacks = require("snacks")
local MiniMisc = require("mini.misc")

local context_menu = dofile(current_dir .. "/context_menu.lua")
local file_cache = dofile(current_dir .. "/file_cache.lua")
local keymap = dofile(current_dir .. "/keymap.lua")
local map, tmap, tmap_no_claude = keymap.map, keymap.tmap, keymap.tmap_no_claude

-- Prevent automatic window resizing when opening/closing splits
vim.o.equalalways = false

-- Buffer navigation: Option-Shift-[ and Option-Shift-] (sent as F13/F14 by terminal)
vim.keymap.set("n", "<F13>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<F14>", "<cmd>bnext<cr>", { desc = "Next buffer" })

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
	on_attach = function(bufnr)
		local api = require("nvim-tree.api")

		-- Apply default nvim-tree keybindings first
		api.config.mappings.default_on_attach(bufnr)

		-- Add buffer-local Shift+Arrow navigation (matches global mappings in mappings.vim)
		local opts = { buffer = bufnr, noremap = true, silent = true }
		vim.keymap.set("n", "<S-Up>", "<C-w><Up>", opts)
		vim.keymap.set("n", "<S-Down>", "<C-w><Down>", opts)
		vim.keymap.set("n", "<S-Left>", "<C-w><Left>", opts)
		vim.keymap.set("n", "<S-Right>", "<C-w><Right>", opts)
	end,
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

	-- Use bat with Tokyo Night theme for fast previews
	previewers = {
		bat = {
			theme = "tokyonight_night",
		},
	},

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

-- File cache for instant file picker
file_cache.setup()

-- Cached file picker
local function cached_files()
	local files = file_cache.get()
	if files and #files > 0 then
		fzf.fzf_exec(files, {
			prompt = "Files❯ ",
			previewer = "builtin",
			actions = fzf.defaults.actions.files,
			file_icons = true,
			color_icons = true,
		})
	else
		-- Fallback if cache not ready
		vim.notify("File cache not ready, searching without cache...", vim.log.levels.WARN)
		fzf.files()
	end
end

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"c",
		"comment",
		"cpp",
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

		-- Ctrl+Click to go to definition (like VS Code)
		vim.keymap.set(
			"n",
			"<C-LeftMouse>",
			"<LeftMouse><cmd>lua vim.lsp.buf.definition()<cr>",
			opts("Go to definition")
		)
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
		"bashls", -- uses shellcheck for diagnostics
		"clangd", -- C/C++
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
		-- shellcheck removed from none-ls; use bashls instead (integrates shellcheck natively)
		null_ls.builtins.diagnostics.markdownlint.with({
			-- Disable line-length rule (MD013) - too noisy for most markdown
			extra_args = { "--disable", "MD013" },
		}),
		null_ls.builtins.diagnostics.yamllint,
		null_ls.builtins.diagnostics.actionlint,

		-- Terraform (tflint removed from none-ls; terraformls provides diagnostics)
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
		"shellcheck", -- not used by none-ls, but bashls needs it for diagnostics
		"shfmt",
		"stylua",
		-- tflint: removed from none-ls, terraformls provides diagnostics
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

-- mini.misc setup (for MiniMisc.zoom)
MiniMisc.setup()

-- -----------------------------------------------------------------------------
-- Snacks
-- -----------------------------------------------------------------------------
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })
map("n", "<leader>go", function()
	Snacks.gitbrowse()
end, { desc = "Open in GitHub" })
map("n", "<leader>rn", function()
	Snacks.rename.rename_file()
end, { desc = "Rename file" })
map("n", "]]", function()
	Snacks.words.jump(1)
end, { desc = "Next reference" })
map("n", "[[", function()
	Snacks.words.jump(-1)
end, { desc = "Prev reference" })

-- Terminal
local function toggleTerminal()
	Snacks.terminal.toggle()
end
local function hideAllTerminals()
	for _, term in ipairs(Snacks.terminal.list()) do
		term:hide()
	end
end
local function killAllTerminals()
	for _, term in ipairs(Snacks.terminal.list()) do
		term:close()
	end
end

map({ "n", "v" }, "<leader>z", toggleTerminal, { desc = "Toggle terminal" })
tmap("<leader>z", toggleTerminal, { desc = "Toggle terminal" })

map({ "n", "v" }, "<leader>x", hideAllTerminals, { desc = "Hide all terminals" })
tmap("<leader>x", hideAllTerminals, { desc = "Hide all terminals" })

map({ "n", "v" }, "<leader>X", killAllTerminals, { desc = "Kill all terminals" })
tmap("<leader>X", killAllTerminals, { desc = "Kill all terminals" })

-- -----------------------------------------------------------------------------
-- Window Zoom (mini.misc)
-- -----------------------------------------------------------------------------
local function zoomWindow()
	MiniMisc.zoom(0, {
		width = vim.o.columns,
		height = vim.o.lines,
		row = 0,
		col = 0,
		border = "double",
		title_pos = "center",
	})
	-- Darken the zoomed window background
	local win = vim.api.nvim_get_current_win()
	vim.wo[win].winblend = 5
	vim.wo[win].winhighlight = "Normal:NormalFloat"
end

map({ "n", "v" }, "<C-S-CR>", zoomWindow, { desc = "Toggle window zoom" })
tmap("<C-S-CR>", function()
	vim.schedule(zoomWindow)
end, { desc = "Toggle window zoom" })

-- claudecode.nvim setup (editor context integration with Claude Code)
require("claudecode").setup({
	log_level = "warn",
	terminal = {
		split_side = "right",
		split_width_percentage = 0.40, -- Fallback for non-Snacks providers
		provider = "snacks",
		snacks_win_opts = {
			width = function()
				local editor_width = vim.o.columns
				local percentage_width = math.floor(editor_width * 0.40)
				return math.min(percentage_width, 75) -- Cap at 75 columns
			end,
		},
	},
	diff_opts = {
		vertical_split = false,
	},
})

-- =============================================================================
-- KEYBINDINGS (helpers from helpers/keymap.lua)
-- =============================================================================

-- NvimTree helpers
local function toggleNvimTree()
	NvimTreeApi.tree.toggle()
	vim.cmd.wincmd("w")
end

local function launchNvimTree()
	NvimTreeApi.tree.open()
	vim.cmd.wincmd("w")
end

-- -----------------------------------------------------------------------------
-- Claude Code
-- -----------------------------------------------------------------------------
map({ "n", "v" }, "<leader>a", ":ClaudeCode<CR>", { desc = "Toggle Claude Code" })
tmap("<leader>a", ":ClaudeCode<CR>", { desc = "Toggle Claude Code" })
map("v", "<leader>a", ":ClaudeCodeSend<CR>", { desc = "Send selection to Claude" })
map("n", "<leader>sa", ":ClaudeCodeAdd<CR>", { desc = "Add file to Claude context" })

-- -----------------------------------------------------------------------------
-- Fuzzy Finder (fzf-lua)
-- -----------------------------------------------------------------------------
map({ "n", "i", "v" }, "<C-p>", cached_files, { desc = "Find files" })
tmap("<C-p>", cached_files, { desc = "Find files" })

map({ "n", "i" }, "<C-o>", fzf.live_grep, { desc = "Live grep" })
map("v", "<C-o>", fzf.grep_visual, { desc = "Grep visual selection" })
tmap_no_claude("<C-o>", fzf.live_grep, { desc = "Live grep" })

map("n", "<leader>ll", cached_files, { desc = "Find files" })
map("n", "<leader>lr", file_cache.force_refresh, { desc = "Refresh file cache" })
map("n", "<leader>lk", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>lj", fzf.grep_cword, { desc = "Grep word under cursor" })

-- -----------------------------------------------------------------------------
-- NvimTree
-- -----------------------------------------------------------------------------
map({ "n", "v" }, "<leader>m", toggleNvimTree, { desc = "Toggle NvimTree" })
tmap("<leader>m", toggleNvimTree, { desc = "Toggle NvimTree" })

map({ "n", "v" }, "<leader>n", ":NvimTreeFindFile<CR>", { desc = "Find file in NvimTree" })
tmap("<leader>n", ":NvimTreeFindFile<CR>", { desc = "Find file in NvimTree" })

map("n", "<leader>b", launchNvimTree, { desc = "Open NvimTree" })

-- -----------------------------------------------------------------------------
-- Git (gitsigns)
-- -----------------------------------------------------------------------------
map("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "Git blame line" })
map("n", ")", ":Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
map("n", "(", ":Gitsigns prev_hunk<CR>", { desc = "Prev git hunk" })

-- -----------------------------------------------------------------------------
-- Context Menu
-- -----------------------------------------------------------------------------
map({ "n", "v" }, "<RightMouse>", context_menu.show, { desc = "Context menu" })

-- Image viewing in terminal (requires ImageMagick: brew install imagemagick)
-- Wrapped in pcall because magick lua dependency can fail to build
local ok, image = pcall(require, "image")
if ok then
	image.setup({
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
end
