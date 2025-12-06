
call plug#begin($VIMPATH . 'bundle')

  " Productivity Plugins
  Plug 'jiangmiao/auto-pairs'
  Plug 'preservim/nerdcommenter'
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}
  Plug 'bronson/vim-trailing-whitespace'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-sleuth'
  Plug 'tpope/vim-repeat'
  Plug 'jmcantrell/vim-virtualenv'
  Plug 'justinmk/vim-sneak'
  Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }

  if has('nvim')
    Plug 'folke/snacks.nvim'
    Plug 'coder/claudecode.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'akinsho/bufferline.nvim'
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'nvim-treesitter/nvim-treesitter'
    Plug 'petertriho/nvim-scrollbar'
    Plug 'lukas-reineke/headlines.nvim'

    " LSP plugins
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'mason-org/mason.nvim'
    Plug 'mason-org/mason-lspconfig.nvim'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'pmizio/typescript-tools.nvim'
    Plug 'VidocqH/lsp-lens.nvim'

    " Fuzzy finder
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    Plug 'nvim-telescope/telescope-ui-select.nvim'

    " Theme
    Plug 'folke/tokyonight.nvim'
  endif

  if !has('nvim')
    Plug 'airblade/vim-gitgutter'
    Plug 'tpope/vim-fugitive'
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    " LSP plugins
    Plug 'prabirshrestha/vim-lsp'
    Plug 'mattn/vim-lsp-settings'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'prabirshrestha/asyncomplete-lsp.vim'

    " Fuzzy Finder
    Plug 'ctrlpvim/ctrlp.vim'

    " Theme
    Plug 'kristijanhusak/vim-hybrid-material'
    Plug 'chriskempson/base16-vim'
  endif

  " Filetype Plugins
  Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
  Plug 'tpope/vim-git', { 'for': 'git' }
  Plug 'mattn/emmet-vim', { 'for': 'html' }
  Plug 'tpope/vim-haml', { 'for': [ 'haml', 'scss', 'sass' ] }
  Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
  Plug 'tpope/vim-rails', { 'for': 'ruby' }
  Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
  Plug 'groenewege/vim-less', { 'for': 'less' }
  Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
  Plug 'avakhov/vim-yaml', { 'for': 'yaml' }
  Plug 'othree/html5.vim', { 'for': 'html' }
  Plug 'othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] }
  Plug 'othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
  Plug 'gavocanov/vim-js-indent', { 'for': ['javascript', 'javascript.jsx'] }
  Plug 'flowtype/vim-flow', { 'for': ['javascript', 'javascript.jsx'] }
  Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript', 'javascript.jsx', 'typescript'] }
  Plug 'leafgarland/typescript-vim', { 'for': ['typescript'] }
  Plug 'elzr/vim-json', { 'for': 'json' }
  Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
  Plug 'LaTeX-Box-Team/LaTeX-Box', { 'for': 'tex' }
  Plug 'vim-scripts/sql.vim--Stinson', { 'for': 'sql' }
  Plug 'vim-scripts/applescript.vim', { 'for': 'applescript' }
  Plug 'hdima/python-syntax', { 'for': 'python' }
  Plug 'vim-scripts/mako.vim', { 'for': 'html' }

  " Configuration File Plugins
  Plug 'vim-scripts/nginx.vim', { 'for': 'nginx' }
  Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }

call plug#end()

