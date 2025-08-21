
" Set syntax highlighting options.
" let base16colorspace=256
set background=dark
" colorscheme base16-tomorrow
colorscheme hybrid_reverse

" Change mapleader
let mapleader = ','
let maplocalleader = ';'

" Create directories
if empty(glob('~/.vim-backups'))
  silent !mkdir -p ~/.vim-backups
endif
if empty(glob('~/.vim-swaps'))
  silent !mkdir -p ~/.vim-swaps
endif
if empty(glob('~/.vim-undo'))
  silent !mkdir -p ~/.vim-undo
endif

" Local dirs
set backupdir=~/.vim-backups
set directory=~/.vim-swaps
set undodir=~/.vim-undo

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
set expandtab " Expand tabs to spaces
set formatoptions=
set formatoptions+=c " Format comments
set formatoptions+=r " Continue comments by default
set formatoptions+=o " Make comment when using o or O from comment line
set formatoptions+=q " Format comments with gq
set formatoptions+=n " Recognize numbered lists
set formatoptions+=2 " Use indent from 2nd line of a paragraph
set formatoptions+=l " Don't break lines that are already long
set formatoptions+=1 " Break before 1-letter words
set formatoptions+=j " Remove comment leader
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

if has('nvim')
  set updatetime=200 " This is so GitGutter updates really fast
else
  set encoding=utf-8 nobomb " BOM often causes trouble
endif

if exists('&breakindent')
  set breakindent showbreak=..
endif

if has('mouse_sgr') && !has('nvim')
  set ttymouse=sgr
endif


