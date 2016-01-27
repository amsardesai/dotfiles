
" Make vim more useful
if exists('&nocompatible')
  set nocompatible
endif

" Determine vim directories
if has('nvim')
  let vimdir = $XDG_CONFIG_HOME . "/nvim/"
else
  let vimdir = "~/.vim/"
endif

" Install plug if it's not already installed
if empty(glob(vimdir . "autoload/plug.vim"))
  execute "!mkdir -p " . vimdir . "autoload/"
  execute "!mkdir -p " . vimdir . "backups/"
  execute "!mkdir -p " . vimdir . "bundle/"
  execute "!mkdir -p " . vimdir . "swaps/"
  execute "!mkdir -p " . vimdir . "undo/"
  execute "!curl -fLo " . vimdir . "autoload/plug.vim --create-dirs " .
        \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Updating remote plugins
function! UpdateRPlugin(info)
  if has('nvim')
    silent UpdateRemotePlugins
    echomsg 'rplugin updated: ' . a:info['name'] . ', restart vim for changes'
  endif
endfunction

call plug#begin(vimdir . "bundle")

  " Productivity Plugins
  Plug 'jiangmiao/auto-pairs'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'scrooloose/nerdcommenter'
  Plug 'scrooloose/nerdtree'
  Plug 'bling/vim-airline'
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'tpope/vim-sleuth'
  Plug 'bronson/vim-trailing-whitespace'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'easymotion/vim-easymotion'

  " nvim vs vim plugins
  if has('nvim')

    Plug 'Shougo/deoplete.nvim', { 'do': function('UpdateRPlugin') }
    Plug 'benekastah/neomake', { 'do': function('UpdateRPlugin') }
    Plug 'mhinz/vim-grepper', { 'do': function('UpdateRPlugin') }

  else

    Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
    Plug 'scrooloose/syntastic', { 'for': [ 'javascript', 'python' ] }
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

  endif

  " Themes
  Plug 'kristijanhusak/vim-hybrid-material'

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
  Plug 'rschmukler/pangloss-vim-indent', { 'for': ['javascript', 'javascript.jsx'] }
  Plug 'othree/vim-jsx', { 'for': 'javascript.jsx' }
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

" Set syntax highlighting options.
set t_Co=256
set background=dark
silent! colorscheme hybrid_reverse

" Change mapleader
let mapleader = ","
let maplocalleader = ";"

" Local dirs
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
set undodir=~/.vim/undo

" Indentation
set autoindent " Copy indent from last line when starting new line.
set backspace=indent,eol,start
set shiftwidth=2
set smartindent
set smarttab " At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shiftwidth spaces.
set softtabstop=2 " Tab key results in 2 spaces
set tabstop=4
set linebreak
set wrap

" Set some junk
set autoread " Automatically load updated file if it's not changed
set colorcolumn=100 " Max length of a line
set cursorline " Highlight current line
set diffopt=filler " Add vertical spaces to keep right and left aligned
" set diffopt+=iwhite " Ignore whitespace changes (focus on code changes)
set encoding=utf-8 nobomb " BOM often causes trouble
set esckeys " Allow cursor keys in insert mode.
set expandtab " Expand tabs to spaces
" set foldcolumn=4 " Column to show folds
" set foldenable
" set foldlevel=5
" set foldlevelstart=99
" set foldmethod=syntax " Markers are used to specify folds.
" set foldminlines=0 " Allow folding single lines
" set foldnestmax=3 " Set max fold nesting level
set formatoptions=
set formatoptions+=c " Format comments
set formatoptions+=r " Continue comments by default
set formatoptions+=o " Make comment when using o or O from comment line
set formatoptions+=q " Format comments with gq
set formatoptions+=n " Recognize numbered lists
set formatoptions+=2 " Use indent from 2nd line of a paragraph
set formatoptions+=l " Don't break lines that are already long
set formatoptions+=1 " Break before 1-letter words
set gdefault " By default add g flag to search/replace. Add g to toggle.
set hidden " When a buffer is brought to foreground, remember undo history and marks.
set history=1000 " Increase history from 20 default to 1000
set hlsearch " Highlight searches
set ignorecase " Ignore case of searches.
set incsearch " Highlight dynamically as pattern is typed.
set laststatus=2 " Always show status line
set magic " Enable extended regexes.
set mouse=a " Enable moouse in all in all modes.
set noerrorbells " Disable error bells.
set nojoinspaces " Only insert single space after a '.', '?' and '!' with a join command.
set noshowmode " Don't show the current mode (Powerline takes care of us)
set nostartofline " Don't reset cursor to start of line when moving around.
set nu " Enable line numbers.
set ofu=syntaxcomplete#Complete " Set omni-completion method.
set pastetoggle=<Leader>u " Set paste toggle
set report=0 " Show all changes.
set ruler " Show the cursor position
set scrolloff=3 " Start scrolling three lines before horizontal border of window.
set shell=\/usr\/bin\/env\ bash\ --login
set showmode " Show the current mode.
set showtabline=2 " Always show tab bar.
set sidescrolloff=3 " Start scrolling three columns before vertical border of window.
set smartcase " Ignore 'ignorecase' if search patter contains uppercase characters.
set splitbelow " New window goes below
set splitright " New windows goes right
set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll
set title " Show the filename in the window titlebar.
set ttyfast " Send more characters at a given time.
set undofile " Persistent Undo.
set visualbell " Use visual bell instead of audible bell (annnnnoying)
set wildchar=<TAB> " Character for CLI expansion (TAB-completion).
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
set wildignore+=*/smarty/*,*/vendor/*,*/node_modules/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*,*/doc/*
set wildmenu " Hitting TAB in command mode will show possible completions above command line.
set wildmode=list:longest " Complete only until point of ambiguity.
set wrapscan " Searches wrap around end of file
set whichwrap+=<,>,h,l,[,]

if exists('&breakindent')
  set breakindent showbreak=..
endif

if exists('&ttymouse')
  set ttymouse=xterm " Set mouse type to xterm.
endif

" Speed up transition from modes
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
  augroup END
endif

" Escape to remove search results
nnoremap <silent> <CR> :noh<CR><CR>

" EasyMotion
map \ <Plug>(easymotion-prefix)

" Faster split resizing (+,-)
if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
endif

" Remap certain keys
command! W write
command! Q quit

" Buffer navigation (,,) (,]) (,[) (,\) (,ls)
map <Leader>, <C-^>
map <Leader>] :bnext<CR>
map <Leader>[ :bprev<CR>
map <Leader>\ :bprevious<CR>:bdelete<SPACE>#<CR>
map <Leader><bar> :bprevious<CR>:bdelete!<SPACE>#<CR>
map <Leader>ls :buffers<CR>

" Close Quickfix window (,qq)
map <Leader>q :cclose<CR>

" Open QuickFix window for grep commands
command! -nargs=+ Gr execute 'silent Ggrep!' <q-args> | cw | redraw!
command! Gl execute 'silent Glog!' | cw | redraw!
autocmd QuickFixCmdPost *grep* cwindow

" Fix Whitespace
nnoremap <leader>fw :FixWhitespace<CR>

" Ctrl-Backspace
imap <C-BS> <C-W>

" Fix page up and down
map <PageUp> <C-U>
map <PageDown> <C-D>
imap <PageUp> <C-O><C-U>
imap <PageDown> <C-O><C-D>

" Switch between .cc and .h files
if index(['c', 'cpp'], &filetype) == -1
  nmap ,gh :e %:p:s,.h$,.X123X,:s,.cc$,.h,:s,.X123X$,.cc,<CR>
endif

" Ruby
au BufRead,BufNewFile Rakefile,Capfile,Gemfile,.autotest,.irbrc,*.treetop,*.tt set ft=ruby

" JSON
au BufRead,BufNewFile .jshintrc,.eslintrc set ft=json

" NERD Commenter
let NERDSpaceDelims=1

" CtrlP.vim
let g:ctrlp_match_window = 'max:50'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let g:ctrlp_dont_split = 'NERD'
map <C-h> :CtrlPBuffer<CR>
map <Leader>op :CtrlPClearAllCaches<CR>

" Airline
let g:airline_theme='tomorrow'
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" NERDTree
let NERDTreeShowHidden=1
let NERDTreeAutoDeleteBuffer=1
nmap <leader>m :NERDTreeToggle<CR><C-w>w
nmap <leader>n :NERDTreeFind<CR>
nmap <leader>b :NERDTree<CR><C-w>w

" Latex
let g:tex_flavor = 'latex'

" Fugitive
nmap <Leader>gk :silent Ggr<space>""<Left>
nmap <silent> <Leader>gl :silent Glog<CR>
nmap <silent> <Leader>gb :Gblame<CR>

" vim-json
set conceallevel=2

" GitGutter
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0

if has('nvim')
  " Neovim specific commands

  " Deoplete
  let g:deoplete#enable_at_startup = 1

  " Neomake
  let g:neomake_javascript_enabled_makers = ['eslint']
  autocmd! BufWritePost * Neomake

  " vim-grepper
  nmap <Leader>gk :Grepper -tool git -switch<CR>

else
  " Old vim specific commands

  " UtiliSnips
  let g:UltiSnipsExpandTrigger = '<C-j>'
  let g:UltiSnipsJumpForwardTrigger = '<C-b>'
  let g:UltiSnipsJumpBackwardTrigger = '<C-z>'

  " YouCompleteMe
  let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
  let g:ycm_path_to_python_interpreter = '/usr/bin/python'
  let g:ycm_confirm_extra_conf = 0

  " Syntastic
  let b:syntastic_mode = 'passive'
  let g:syntastic_enable_signs = 1
  let g:syntastic_javascript_checkers = ['eslint']
  nmap <Leader>sk :SyntasticToggleMode<CR>
  nmap <Leader>sr :SyntasticReset<CR>
  nmap <Leader>si :SyntasticInfo<CR>
  nmap <Leader>sc :SyntasticCheck<CR>

endif

