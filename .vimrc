" Make vim more useful
set nocompatible

" Enabled later, after Vundle
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
  " Plugins
  Plugin 'gmarik/Vundle.vim'
  Plugin 'jiangmiao/auto-pairs'
  Plugin 'kien/ctrlp.vim'
  Plugin 'scrooloose/nerdcommenter'
  Plugin 'scrooloose/nerdtree'
  Plugin 'kien/rainbow_parentheses.vim'
  Plugin 'bling/vim-airline'
  Plugin 'airblade/vim-gitgutter'
  Plugin 'tpope/vim-fugitive'
  Plugin 'Valloric/YouCompleteMe'
  Plugin 'terryma/vim-multiple-cursors'
  Plugin 'tpope/vim-sleuth'
  Plugin 'flazz/vim-colorschemes'
  Plugin 'bronson/vim-trailing-whitespace'
  Plugin 'tpope/vim-git'
  Plugin 'surround.vim'
  Plugin 'SirVer/ultisnips'
  Plugin 'honza/vim-snippets'
  Plugin 'LaTeX-Box-Team/LaTeX-Box'
  Plugin 'scrooloose/syntastic'
  Plugin 'majutsushi/tagbar'
  " Plugin 'Xuyuanp/nerdtree-git-plugin'

  " Languages / Frameworks
  Plugin 'mattn/emmet-vim'
  Plugin 'tpope/vim-haml'
  Plugin 'vim-ruby/vim-ruby'
  Plugin 'tpope/vim-rails'
  Plugin 'kchmck/vim-coffee-script'
  Plugin 'groenewege/vim-less'
  Plugin 'digitaltoad/vim-jade'
  Plugin 'othree/html5.vim'
  Plugin 'othree/yajs.vim'
  Plugin 'rschmukler/pangloss-vim-indent'
  Plugin 'othree/vim-jsx'
  Plugin 'elzr/vim-json'
  Plugin 'nginx.vim'
  Plugin 'derekwyatt/vim-scala'

call vundle#end()


" Set syntax highlighting options.
set t_Co=256
set background=dark
syntax on
colorscheme hybrid

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
set shiftwidth=2 " The # of spaces for indenting.
set smartindent
set smarttab " At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shiftwidth spaces.
set softtabstop=2 " Tab key results in 2 spaces
set tabstop=4
set breakindent showbreak=..
set linebreak
set wrap

" Set some junk
set autoread " Automatically load updated file if it's not changed
set cursorline " Highlight current line
set diffopt=filler " Add vertical spaces to keep right and left aligned
" set diffopt+=iwhite " Ignore whitespace changes (focus on code changes)
set encoding=utf-8 nobomb " BOM often causes trouble
set esckeys " Allow cursor keys in insert mode.
set expandtab " Expand tabs to spaces
set foldcolumn=4 " Column to show folds
set foldenable
set foldlevel=5
set foldlevelstart=99
set foldmethod=syntax " Markers are used to specify folds.
" set foldminlines=0 " Allow folding single lines
set foldnestmax=3 " Set max fold nesting level
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
set report=0 " Show all changes.
set ruler " Show the cursor position
set scrolloff=3 " Start scrolling three lines before horizontal border of window.
set shell=\/usr\/bin\/env\ bash\ --login
set shortmess=atI " Don't show the intro message when starting vim.
set showmode " Show the current mode.
set showtabline=2 " Always show tab bar.
set sidescrolloff=3 " Start scrolling three columns before vertical border of window.
set smartcase " Ignore 'ignorecase' if search patter contains uppercase characters.
set splitbelow " New window goes below
set splitright " New windows goes right
set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll
set title " Show the filename in the window titlebar.
set ttyfast " Send more characters at a given time.
set ttymouse=xterm " Set mouse type to xterm.
set undofile " Persistent Undo.
set visualbell " Use visual bell instead of audible bell (annnnnoying)
set wildchar=<TAB> " Character for CLI expansion (TAB-completion).
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
set wildignore+=*/smarty/*,*/vendor/*,*/node_modules/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*,*/doc/*
set wildmenu " Hitting TAB in command mode will show possible completions above command line.
set wildmode=list:longest " Complete only until point of ambiguity.
set winminheight=0 "Allow splits to be reduced to a single line.
set wrapscan " Searches wrap around end of file
set whichwrap+=<,>,h,l,[,]

" Change the way up and down is interpreted
noremap  <buffer> <silent> <Up>   gk
noremap  <buffer> <silent> <Down> gj
noremap  <buffer> <silent> k      gk
noremap  <buffer> <silent> j      gj
noremap  <buffer> <silent> 0      g0
noremap  <buffer> <silent> $      g$
inoremap <buffer> <silent> <Up>   <C-o>gk
inoremap <buffer> <silent> <Down> <C-o>gj

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

" Faster split resizing (+,-)
if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
endif

" Remap certain keys
command! W write
command! Q quit

" NERD Commenter
let NERDSpaceDelims=1

" Buffer navigation (,,) (,]) (,[) (,\) (,ls)
map <leader>, <C-^>
map <leader>] :bnext<CR>
map <leader>[ :bprev<CR>
map <leader>\ :bprevious<CR>:bdelete<SPACE>#<CR>
map <leader><bar> :enew<CR>
map <leader>ls :buffers<CR>

" Close Quickfix window (,qq)
map <leader>q :cclose<CR>

" Open QuickFix window for grep commands
command! -nargs=+ Gr execute 'silent Ggrep!' <q-args> | cw | redraw!
command! Gl execute 'silent Glog!' | cw | redraw!
autocmd QuickFixCmdPost *grep* cwindow

" Fix Whitespace
nnoremap <leader>fw :FixWhitespace<CR>

" Search and replace word under cursor (,*)
nnoremap <leader>* :%s/\<<C-r><C-w>\>//<Left>

" Auto close html tags
iabbrev <// </<C-X><C-O>

" Ctrl-Backspace
imap <C-BS> <C-W>

" Fix page up and down
map <PageUp> <C-U>
map <PageDown> <C-D>
imap <PageUp> <C-O><C-U>
imap <PageDown> <C-O><C-D>

" Restore cursor position
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" Ruby
au BufRead,BufNewFile Rakefile,Capfile,Gemfile,.autotest,.irbrc,*.treetop,*.tt set ft=ruby

" JSON
au BufRead,BufNewFile .jshintrc,.eslintrc set ft=json

" CtrlP.vim
let g:ctrlp_match_window = 'max:50'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let g:ctrlp_dont_split = 'NERD'
map <C-h> :CtrlPBuffer<CR>
map <Leader>op :CtrlPClearAllCaches<CR>

" CtrlPFunky
map <C-t> :CtrlPFunky<CR>

" RainbowParenthesis.vim
nnoremap <leader>rr :RainbowParenthesesToggle<CR>

" Emulate bundles, allow plugins to live independantly. Easier to manage.
filetype plugin indent on

" Airline
let g:airline_theme='tomorrow'
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" NERDTree
let NERDTreeShowHidden=1
nmap <leader>m :NERDTreeToggle<CR><C-w>w
nmap <leader>n :NERDTreeFind<CR>
nmap <leader>b :NERDTree<CR><C-w>w

" UtiliSnips
let g:UltiSnipsExpandTrigger = '<C-j>'
let g:UltiSnipsJumpForwardTrigger = '<C-b>'
let g:UltiSnipsJumpBackwardTrigger = '<C-z>'

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_path_to_python_interpreter = '/usr/bin/python'

" Syntastic
let b:syntastic_mode = 'passive'
let g:syntastic_enable_signs = 1
let g:syntastic_javascript_checkers = ['eslint']
nmap <Leader>sk :SyntasticToggleMode<CR>:SyntasticReset<CR>
nmap <Leader>si :SyntasticInfo<CR>
nmap <Leader>sc :SyntasticCheck<CR>

" Latex
let g:tex_flavor = 'latex'

" Fugitive
nmap <Leader>gk :silent Ggr<space>
nmap <silent> <Leader>gl :silent Glog<CR>
nmap <silent> <Leader>gb :Gblame<CR>

" vim-json
set conceallevel=2

" GitGutter
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0


