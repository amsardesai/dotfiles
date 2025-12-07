-- Language Plugins: Treesitter, language-specific tools

return {
	-- =============================================================================
	-- TREESITTER (BufReadPost)
	-- =============================================================================

	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash", "c", "comment", "cpp", "css", "dockerfile",
					"git_config", "git_rebase", "gitignore", "gitcommit", "go",
					"html", "jsdoc", "json", "lua", "markdown", "markdown_inline",
					"python", "ruby", "typescript", "tsx", "tsv", "vim", "vimdoc", "yaml",
				},
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
					separate_diagnostic_server = true,
					tsserver_max_memory = 16384,
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
