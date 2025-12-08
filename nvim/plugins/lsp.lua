-- LSP Plugins: Language servers, completion, linting, formatting

return {
	-- =============================================================================
	-- LSP & MASON (BufReadPre)
	-- =============================================================================

	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Add Mason bin to PATH
			vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

			-- Border style for all floating windows
			local border = "rounded"

			-- Diagnostic config with bordered floats
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				update_in_insert = false,
				underline = true,
				severity_sort = false,
				float = {
					border = border,
					source = true,
				},
			})

			-- Add border to LSP hover and signature help
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = border,
			})
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = border,
			})

			-- Strike through deprecated
			vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { strikethrough = true, fg = "#5c6370" })

			-- Auto-show diagnostics on cursor hold
			vim.o.updatetime = 250
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					vim.diagnostic.open_float(nil, { focusable = false, border = border })
				end,
			})

			-- LSP keybindings
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = function(desc)
						return { buffer = event.buf, desc = desc }
					end
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover documentation"))
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
					vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts("Go to type definition"))
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Find references"))
					vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts("Signature help"))
					vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts("Rename symbol"))
					vim.keymap.set({ "n", "x" }, "<F3>", function()
						vim.lsp.buf.format({ async = true })
					end, opts("Format"))
					vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts("Code actions"))
					vim.keymap.set("n", "gh", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end, opts("Toggle inlay hints"))
					vim.keymap.set(
						"n",
						"<C-LeftMouse>",
						"<LeftMouse><cmd>lua vim.lsp.buf.definition()<cr>",
						opts("Go to definition")
					)
				end,
			})

			-- Mason setup
			require("mason").setup()

			-- Capabilities for completion
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local default_setup = function(server)
				require("lspconfig")[server].setup({ capabilities = capabilities })
			end

			require("mason-lspconfig").setup({
				ensure_installed = {
					"bashls",
					"clangd",
					"cssls",
					"docker_compose_language_service",
					"docker_language_server",
					"dockerls",
					"html",
					"jsonls",
					"lua_ls",
					"pylsp",
					"terraformls",
					"vimls",
					"yamlls",
				},
				automatic_enable = true,
				handlers = {
					default_setup,
					-- Disable ts_ls since typescript-tools.nvim handles TypeScript
					ts_ls = function() end,
					-- Disable eslint LSP since eslint_d via none-ls is faster
					eslint = function() end,
				},
			})
		end,
	},

	{ "mason-org/mason.nvim", lazy = true },
	{ "mason-org/mason-lspconfig.nvim", lazy = true },

	-- =============================================================================
	-- LSP-LENS (LspAttach)
	-- =============================================================================

	{
		"VidocqH/lsp-lens.nvim",
		event = "LspAttach",
		keys = {
			{ "gL", "<cmd>LspLensToggle<cr>", desc = "Toggle LSP lens" },
		},
		config = function()
			local SymbolKind = vim.lsp.protocol.SymbolKind
			require("lsp-lens").setup({
				enable = true,
				include_declaration = false,
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
					-- NOTE: These are nerd font icons - do NOT replace with ASCII!
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
		end,
	},

	-- =============================================================================
	-- NONE-LS (BufReadPre)
	-- =============================================================================

	{
		"nvimtools/none-ls.nvim",
		event = "BufReadPre",
		dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
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
					null_ls.builtins.diagnostics.hadolint,
					null_ls.builtins.diagnostics.markdownlint.with({
						extra_args = { "--disable", "MD013" },
					}),
					null_ls.builtins.diagnostics.yamllint,
					null_ls.builtins.diagnostics.actionlint,
					null_ls.builtins.formatting.terraform_fmt,
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
						condition = function()
							return true
						end,
					}),
					null_ls.builtins.formatting.biome.with({
						filetypes = { "javascript", "javascriptreact", "json", "typescript", "typescriptreact" },
						condition = function(utils)
							return utils.root_has_file({ "biome.json", "biome.jsonc" })
						end,
					}),
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.shfmt,
				},
			})

			-- Register eslint_d
			null_ls.register(require("none-ls.diagnostics.eslint_d"))
			null_ls.register(require("none-ls.formatting.eslint_d"))

			-- Format on save
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
		end,
	},

	{ "nvimtools/none-ls-extras.nvim", lazy = true },

	{
		"jay-babu/mason-null-ls.nvim",
		event = "BufReadPre",
		dependencies = { "mason-org/mason.nvim", "nvimtools/none-ls.nvim" },
		opts = {
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
				"yamllint",
			},
			automatic_installation = true,
			handlers = {},
		},
	},

	-- =============================================================================
	-- COMPLETION (InsertEnter)
	-- =============================================================================

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"windwp/nvim-autopairs",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<C-Space>"] = cmp.mapping.complete(),
				}),
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
			})

			-- Autopairs integration
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	{ "hrsh7th/cmp-nvim-lsp", lazy = true },
	{ "hrsh7th/cmp-buffer", lazy = true },
	{ "hrsh7th/cmp-path", lazy = true },

	{
		"hrsh7th/cmp-cmdline",
		event = "CmdlineEnter",
	},

	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		build = "make install_jsregexp",
	},

	-- =============================================================================
	-- AUTOPAIRS (InsertEnter)
	-- =============================================================================

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = { check_ts = true },
	},
}
