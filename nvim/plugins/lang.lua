-- Language Plugins: Treesitter, language-specific tools

return {
	-- =============================================================================
	-- TREESITTER (BufReadPost)
	-- =============================================================================

	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ensure_installed = {
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
				"python",
				"ruby",
				"typescript",
				"tsx",
				"tsv",
				"vim",
				"vimdoc",
				"yaml",
			}

			local ok, treesitter = pcall(require, "nvim-treesitter")
			if ok and type(treesitter.install) == "function" then
				treesitter.setup({
					install_dir = vim.fn.stdpath("data") .. "/site",
				})
				treesitter.install(ensure_installed)

				local group = vim.api.nvim_create_augroup("ankit.treesitter", { clear = true })
				vim.api.nvim_create_autocmd("FileType", {
					group = group,
					callback = function(args)
						pcall(vim.treesitter.start, args.buf)
					end,
				})
				return
			end

			local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
			if not ok_configs then
				return
			end

			configs.setup({
				ensure_installed = ensure_installed,
				highlight = { enable = true },
			})
		end,
	},

	-- =============================================================================
	-- TYPESCRIPT-TOOLS (filetype-specific)
	-- =============================================================================

	{
		"pmizio/typescript-tools.nvim",
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("typescript-tools").setup({
				capabilities = capabilities,
				settings = {
					separate_diagnostic_server = false, -- Disabled to reduce tsserver instances in monorepos
					tsserver_max_memory = 28672, -- 28GB for large monorepos (Notion uses this for 64GB+ machines)
					jsx_close_tag = {
						enable = true,
						filetypes = { "javascriptreact", "typescriptreact" },
					},
					code_lens = "off",
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
			-- Attach to current buffer (fixes race condition when lazy-loaded via ft)
			vim.schedule(function()
				vim.cmd("LspStart typescript-tools")
			end)
		end,
	},

	-- =============================================================================
	-- HEADLINES (markdown)
	-- =============================================================================

	{
		"lukas-reineke/headlines.nvim",
		ft = "markdown",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {},
	},

	-- =============================================================================
	-- FILETYPE PLUGINS
	-- =============================================================================

	{ "mattn/emmet-vim", ft = { "html", "css", "javascriptreact", "typescriptreact" } },
	{ "vim-ruby/vim-ruby", ft = "ruby" },
	{ "tpope/vim-rails", ft = "ruby" },
	{ "derekwyatt/vim-scala", ft = "scala" },
	{ "LaTeX-Box-Team/LaTeX-Box", ft = "tex" },
	{ "vim-scripts/sql.vim--Stinson", ft = "sql" },
	{ "vim-scripts/applescript.vim", ft = "applescript" },
	{ "vim-scripts/mako.vim", ft = "html" },
	{ "vim-scripts/nginx.vim", ft = "nginx" },
	{ "jmcantrell/vim-virtualenv", ft = "python" },
}
