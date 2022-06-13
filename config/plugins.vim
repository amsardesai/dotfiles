
call plug#begin($VIMPATH . 'bundle')

  " Productivity Plugins
  Plug 'jiangmiao/auto-pairs'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'scrooloose/nerdcommenter'
  Plug 'scrooloose/nerdtree'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'airblade/vim-gitgutter'
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}
  Plug 'bronson/vim-trailing-whitespace'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-sleuth'
  Plug 'tpope/vim-repeat'
  Plug 'jmcantrell/vim-virtualenv'
  Plug 'justinmk/vim-sneak'
  Plug 'prabirshrestha/vim-lsp'
  Plug 'mattn/vim-lsp-settings'
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-lsp.vim'

  " Themes
  Plug 'kristijanhusak/vim-hybrid-material'
  Plug 'chriskempson/base16-vim'

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

