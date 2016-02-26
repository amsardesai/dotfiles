
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
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'tpope/vim-sleuth'
  Plug 'bronson/vim-trailing-whitespace'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'easymotion/vim-easymotion'
  Plug 'jmcantrell/vim-virtualenv'

  " nvim vs vim plugins
  if has('nvim')

    Plug 'Shougo/deoplete.nvim', { 'do': function('UpdateRPlugin') }
    Plug 'benekastah/neomake', { 'do': function('UpdateRPlugin') }
    Plug 'mhinz/vim-grepper', { 'do': function('UpdateRPlugin') }
    Plug 'Shougo/neosnippet.vim'
      \ | Plug 'Shougo/neosnippet-snippets'
      \ | Plug 'Shougo/neopairs.vim'
    Plug 'ternjs/tern_for_vim', { 'do': 'npm install', 'for': ['javascript', 'javascript.jsx'] }

  else

    Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
    Plug 'scrooloose/syntastic', { 'for': ['javascript', 'javascript.jsx', 'python'] }
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
set report=0 " Show all changes.
set ruler " Show the cursor position
set scrolloff=3 " Start scrolling three lines before horizontal border of window.
" set shell="/bin/bash --login"
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
  set updatetime=500
else
  set encoding=utf-8 nobomb " BOM often causes trouble
endif

if exists('&breakindent')
  set breakindent showbreak=..
endif

if exists('&ttymouse')
  set ttymouse=xterm " Set mouse type to xterm.
endif

if exists(':terminal')
  nnoremap <Leader>z :terminal<CR>
  nnoremap <Leader>x :vsp<CR>:terminal<CR>
  tnoremap <Leader>z <C-\><C-n>:terminal<CR>
  tnoremap <Leader>x <C-\><C-n>:vsp<CR><C-\><C-n>:terminal<CR>

  " Better escaping
  tnoremap ;;q <C-\><C-n>:bd!<CR>
  tnoremap <ESC><ESC> <C-\><C-n>

  " Pane navigation
  tnoremap <S-Left> <C-\><C-n><C-w><Left>
  tnoremap <S-Up> <C-\><C-n><C-w><Up>
  tnoremap <S-Down> <C-\><C-n><C-w><Down>
  tnoremap <S-Right> <C-\><C-n><C-w><Right>
  tnoremap <C-w><Left> <C-\><C-n><C-w><Left>
  tnoremap <C-w><Up> <C-\><C-n><C-w><Up>
  tnoremap <C-w><Down> <C-\><C-n><C-w><Down>
  tnoremap <C-w><Right> <C-\><C-n><C-w><Right>

  " Re-source this file
  tnoremap <Leader>rs <C-\><C-n>:source $MYVIMRC<CR>

  " Buffer navigation (,]) (,[)
  tnoremap <Leader>, <C-\><C-n><C-^>
  tnoremap <Leader>] <C-\><C-n>:bnext<CR>
  tnoremap <Leader>[ <C-\><C-n>:bprevious<CR>
  tmap <Leader>\ <C-\><C-n>:bprevious<CR><C-\><C-n>:bdelete<SPACE>#<CR>
  tmap <Leader><bar> <C-\><C-n>:bprevious<CR><C-\><C-n>:bdelete!<SPACE>#<CR>
  tnoremap <Leader>ls <C-\><C-n>:buffers<CR>

  " Redraw screen if something weird happens
  tnoremap <Leader>rd <C-\><C-n>:redraw!<CR>

  " Insert on enter, normal on leave
  autocmd BufWinEnter,WinEnter term://* startinsert
  autocmd BufLeave term://* stopinsert
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
noremap \ <Plug>(easymotion-prefix)

" Brackets for easier page movement
nnoremap _ 10k0
nnoremap + 10j0
vnoremap _ 10k0
vnoremap + 10j0

" Remap certain keys
command! W write
command! Q quit

" Buffer navigation (,,) (,]) (,[) (,\) (,ls)
nnoremap <Leader>, <C-^>
nnoremap <Leader>] :bnext<CR>
nnoremap <Leader>[ :bprevious<CR>
nnoremap <Leader>\ :bprevious<CR>:bdelete<SPACE>#<CR>
nnoremap <Leader><bar> :bprevious<CR>:bdelete!<SPACE>#<CR>
nnoremap <Leader>ls :buffers<CR>
nnoremap <Leader>v :vsplit<CR>

" Pane switching
nnoremap <S-Up> <C-w><Up>
nnoremap <S-Down> <C-w><Down>
nnoremap <S-Left> <C-w><Left>
nnoremap <S-Right> <C-w><Right>
inoremap <S-Up> <C-w><Up>
inoremap <S-Down> <C-w><Down>
inoremap <S-Left> <C-w><Left>
inoremap <S-Right> <C-w><Right>
vnoremap <S-Up> <C-w><Up>
vnoremap <S-Down> <C-w><Down>
vnoremap <S-Left> <C-w><Left>
vnoremap <S-Right> <C-w><Right>

" Close Quickfix window (,qq)
noremap <Leader>q :cclose<CR>:pclose<CR>

" Redraw screen if something weird happens
nnoremap <Leader>rd :redraw!<CR>

" Re-source this file
nnoremap <Leader>rs :source $MYVIMRC<CR>

" Open QuickFix window for grep commands
command! -nargs=+ Gr execute 'silent Ggrep!' <q-args> | cw | redraw!
command! Gl execute 'silent Glog!' | cw | redraw!
autocmd QuickFixCmdPost *grep* cwindow

" Fix Whitespace
nnoremap <Leader>fw :FixWhitespace<CR>

" Ctrl-Backspace
inoremap <C-BS> <C-W>

" Fix page up and down
noremap <PageUp> <C-U>
noremap <PageDown> <C-D>
inoremap <PageUp> <C-O><C-U>
inoremap <PageDown> <C-O><C-D>

" Switch between .cc and .h files
if index(['c', 'cpp'], &filetype) == -1
  nnoremap ,gh :e %:p:s,.h$,.X123X,:s,.cc$,.h,:s,.X123X$,.cc,<CR>
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
noremap <C-h> :CtrlPBuffer<CR>
noremap <Leader>op :CtrlPClearAllCaches<CR>

" Airline
let g:airline_theme='tomorrow'
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ycm#error_symbol = 'error:'
let g:airline#extensions#ycm#warning_symbol = 'warning:'
let g:airline_powerline_fonts = 1

" NERDTree
let NERDTreeShowHidden=1
let NERDTreeAutoDeleteBuffer=1
nnoremap <leader>m :NERDTreeToggle<CR><C-w>w
nnoremap <leader>n :NERDTreeFind<CR>
nnoremap <leader>b :NERDTree<CR><C-w>w

" Latex
let g:tex_flavor = 'latex'

" Fugitive
nnoremap <silent> <Leader>gl :silent Glog<CR>
nnoremap <silent> <Leader>gb :Gblame<CR>

" vim-json
set conceallevel=2

" Vim markdown
let g:vim_markdown_folding_disabled = 1

" GitGutter
nmap ) <Plug>GitGutterNextHunk
nmap ( <Plug>GitGutterPrevHunk

if has('nvim')
  " Neovim specific commands

  " Function to check if whitespace exists
  function! s:is_whitespace() "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~? '\s'
  endfunction

  " Deoplete
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#file#enable_buffer_path = 1

  " Key bindings for completion for deoplete
  inoremap <silent> <expr> <Tab> pumvisible() ? "\<C-n>" :
      \ (<SID>is_whitespace() ? "\<Tab>" : deoplete#mappings#manual_complete())
  inoremap <silent> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
  inoremap <silent> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
  inoremap <silent> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"

  " Tern for vim
  autocmd FileType javascript setlocal omnifunc=tern#Complete
  let g:tern_show_signature_in_pum = 1

  " Neomake
  let g:neomake_javascript_enabled_makers = ['eslint']
  autocmd! BufWritePost * Neomake
  hi NeomakeError cterm=underline ctermfg=167 ctermbg=52 gui=undercurl
  hi NeomakeWarning cterm=underline ctermfg=172 ctermbg=58 gui=undercurl
  let g:neomake_error_sign = { 'text': '!>', 'texthl': 'NeomakeError' }
  let g:neomake_warning_sign = { 'text': '!>', 'texthl': 'NeomakeWarning' }

  " vim-grepper
  nnoremap <Leader>gk :Grepper -tool git -switch<CR>
  vnoremap <Leader>gk :Grepper -tool git -cword -switch<CR>

else
  " Old vim specific commands

  " Options
  set pastetoggle=<Leader>u " Set paste toggle

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
  nnoremap <Leader>sk :SyntasticToggleMode<CR>
  nnoremap <Leader>sr :SyntasticReset<CR>
  nnoremap <Leader>si :SyntasticInfo<CR>
  nnoremap <Leader>sc :SyntasticCheck<CR>

  " GitGutter
  let g:gitgutter_realtime = 0
  let g:gitgutter_eager = 0

endif

" Make ZZ behave
function! BehaveZZ()
    " Get the number of *listed* buffers.
    let highbuf = bufnr("$")
    let buflist = []
    let i = 1
    while (i <= highbuf)
        "Skip unlisted buffers.
        if (bufexists(i) != 0 && buflisted(i))
            call add(buflist, i)
        endif
        let i = i + 1
    endwhile
    let bufcount = len(buflist)
    if (bufcount == 1)
        if (bufname("%") == "")
            " This buffer is unnamed (has no associated file).
            if (&modified)
                " Give option to save modifications.
                let choice = input("Lose modifications? [Enter=yes]: ")
                if (choice == "")
                    set nomodified
                else
                    echo "ZZ action aborted..."
                    return
                endif
            else
                " The buffer has no modifications. Just do default ZZ.
                execute "x"
            endif
        else
            " There is only one listed buffer and it is named. In this case, 
            " the standard ZZ works just fine, so do that.
            execute "x"
        endif
    elseif (getbufvar(bufnr("%"), "&buftype") != "")
        " This buffer is a "special" buffer.
        execute "bdelete"
    elseif (bufname("%") == "")
        " This buffer is unnamed (has no associated file).
        if (&modified)
            " Give option to save modifications.
            let choice = input("Lose modifications? [Enter=yes]: ")
            if (choice == "")
                set nomodified
            else
                echo "ZZ action aborted..."
                return
            endif
        endif
        if (winnr("$") > 1)
            " There are multiple windows open. Just do a normal ZZ.
            execute "x"
        else
            execute "buffer! " . bufnr("#")
        endif
    else
        " This is a named buffer. 
        if (&modified)
            execute "write"
        endif
        if (winnr("$") > 1)
            " There are multiple windows. Just do normal ZZ.
            execute "x"
        else
            " There is only one window, but multiple listed buffers.
            let curbuf = bufnr("%")
            " If we have a 'last visited' buffer, go there. Else bnext.
            if (bufnr("#") != -1)
                execute "buffer! " . bufnr("#")
            else
                execute "bnext"
            endif
            execute "bdelete" . curbuf
        endif
    endif
endfunction
map ZZ :call BehaveZZ()<CR>

