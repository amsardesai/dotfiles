-- Neovim Plugin Specifications (lazy.nvim)
-- Plugin configurations are in nvimconfig/main.lua

return {
  -- =============================================================================
  -- CORE - Load immediately (required by main.lua at startup)
  -- =============================================================================

  -- Theme (must load first for colorscheme)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Dependencies (loaded when needed by other plugins)
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- UI plugins (main.lua requires these immediately)
  { "folke/snacks.nvim", lazy = false, priority = 900 },
  { "echasnovski/mini.nvim", lazy = false },
  { "nvim-tree/nvim-tree.lua", lazy = false },
  { "nvim-lualine/lualine.nvim", lazy = false },
  { "akinsho/bufferline.nvim", lazy = false, dependencies = "nvim-tree/nvim-web-devicons" },
  { "lewis6991/gitsigns.nvim", lazy = false },
  { "petertriho/nvim-scrollbar", lazy = false },

  -- =============================================================================
  -- FUZZY FINDER
  -- =============================================================================

  {
    "ibhagwan/fzf-lua",
    lazy = false, -- main.lua sets up keybindings that require it
    dependencies = "nvim-tree/nvim-web-devicons",
  },

  -- =============================================================================
  -- TREESITTER
  -- =============================================================================

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- main.lua configures this
    build = ":TSUpdate",
  },

  -- =============================================================================
  -- LSP & MASON
  -- =============================================================================

  -- Note: These load immediately because main.lua configures them at startup.
  -- For true lazy-loading, move configs from main.lua into plugin spec's `config`.

  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  {
    "mason-org/mason.nvim",
    lazy = false,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
  },

  -- TypeScript (direct tsserver communication)
  {
    "pmizio/typescript-tools.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  },

  -- LSP Lens (reference/implementation counts)
  {
    "VidocqH/lsp-lens.nvim",
    lazy = false,
  },

  -- =============================================================================
  -- LINTERS & FORMATTERS (none-ls)
  -- =============================================================================

  {
    "nvimtools/none-ls.nvim",
    lazy = false,
    dependencies = "nvim-lua/plenary.nvim",
  },

  {
    "nvimtools/none-ls-extras.nvim",
    lazy = false,
    dependencies = "nvimtools/none-ls.nvim",
  },

  {
    "jay-babu/mason-null-ls.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "nvimtools/none-ls.nvim" },
  },

  -- =============================================================================
  -- COMPLETION & SNIPPETS
  -- =============================================================================

  {
    "hrsh7th/nvim-cmp",
    lazy = false, -- main.lua configures this
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
  },

  { "hrsh7th/cmp-nvim-lsp", lazy = false },
  { "hrsh7th/cmp-buffer", lazy = false },
  { "hrsh7th/cmp-path", lazy = false },

  {
    "hrsh7th/cmp-cmdline",
    event = "CmdlineEnter",
  },

  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    build = "make install_jsregexp",
  },

  -- =============================================================================
  -- FILETYPE-SPECIFIC
  -- =============================================================================

  -- Markdown headlines
  {
    "lukas-reineke/headlines.nvim",
    ft = "markdown",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup()
    end,
  },

  -- Image viewing (requires ImageMagick CLI: brew install imagemagick)
  -- Disable luarocks build - the magick lua library has build issues
  -- image.nvim works fine with just magick_cli processor
  {
    "3rd/image.nvim",
    lazy = false,
    build = false, -- Disable luarocks build (magick rock fails to build)
  },

  -- =============================================================================
  -- CLAUDE CODE INTEGRATION
  -- =============================================================================

  {
    "coder/claudecode.nvim",
    lazy = false, -- main.lua configures this
  },

  -- =============================================================================
  -- SHARED PLUGINS (formerly managed by vim-plug for both vim/nvim)
  -- =============================================================================

  {
    "jiangmiao/auto-pairs",
    event = "InsertEnter",
  },

  {
    "preservim/nerdcommenter",
    keys = { { "<leader>c", mode = { "n", "v" } } },
  },

  {
    "mg979/vim-visual-multi",
    branch = "master",
    keys = { "<C-n>" },
    init = function()
      -- Disable Shift+Arrow mappings (we use them for pane navigation)
      vim.g.VM_maps = {
        ["Select h"] = "", -- Disable <S-Left>
        ["Select l"] = "", -- Disable <S-Right>
      }
    end,
  },

  {
    "bronson/vim-trailing-whitespace",
    event = "BufWritePre",
  },

  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },

  {
    "tpope/vim-sleuth",
    event = "BufReadPre",
  },

  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  {
    "jmcantrell/vim-virtualenv",
    ft = "python",
  },

  {
    "justinmk/vim-sneak",
    keys = { "s", "S" },
  },

  -- =============================================================================
  -- FILETYPE PLUGINS (lazy-loaded by filetype)
  -- =============================================================================

  { "plasticboy/vim-markdown", ft = "markdown" },
  { "tpope/vim-git", ft = "git" },
  { "mattn/emmet-vim", ft = "html" },
  { "tpope/vim-haml", ft = { "haml", "scss", "sass" } },
  { "vim-ruby/vim-ruby", ft = "ruby" },
  { "tpope/vim-rails", ft = "ruby" },
  { "kchmck/vim-coffee-script", ft = "coffee" },
  { "groenewege/vim-less", ft = "less" },
  { "digitaltoad/vim-jade", ft = "jade" },
  { "avakhov/vim-yaml", ft = "yaml" },
  { "othree/html5.vim", ft = "html" },
  { "othree/yajs.vim", ft = { "javascript", "javascript.jsx" } },
  { "othree/es.next.syntax.vim", ft = { "javascript", "javascript.jsx" } },
  { "gavocanov/vim-js-indent", ft = { "javascript", "javascript.jsx" } },
  { "flowtype/vim-flow", ft = { "javascript", "javascript.jsx" } },
  { "maxmellon/vim-jsx-pretty", ft = { "javascript", "javascript.jsx", "typescript" } },
  { "leafgarland/typescript-vim", ft = "typescript" },
  { "elzr/vim-json", ft = "json" },
  { "derekwyatt/vim-scala", ft = "scala" },
  { "LaTeX-Box-Team/LaTeX-Box", ft = "tex" },
  { "vim-scripts/sql.vim--Stinson", ft = "sql" },
  { "vim-scripts/applescript.vim", ft = "applescript" },
  { "hdima/python-syntax", ft = "python" },
  { "vim-scripts/mako.vim", ft = "html" },

  -- Configuration file plugins
  { "vim-scripts/nginx.vim", ft = "nginx" },
  { "ekalinin/Dockerfile.vim", ft = "Dockerfile" },
}
