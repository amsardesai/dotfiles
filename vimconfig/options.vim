
" ============================================================
" Visual & Theme Settings
" ============================================================

set background=dark " Use dark background for color scheme
" let base16colorspace=256

if has('nvim')
  colorscheme tokyonight-night
else
  colorscheme hybrid_reverse
endif

" ============================================================
" Leader Keys
" ============================================================

let mapleader = ','
let maplocalleader = ';'

" ============================================================
" File & Directory Settings
" ============================================================

set backup " Create backup files before overwriting
set undofile " Persist undo history across sessions
set autoread " Automatically reload file if changed externally

" Auto-reload files changed externally (e.g., by AI tools)
" Check on focus, buffer enter, and periodically when idle
augroup AutoReloadFiles
  autocmd!
  autocmd FocusGained,BufEnter * checktime
  autocmd CursorHold,CursorHoldI * checktime
augroup END

" ============================================================
" Indentation Settings
" ============================================================

set autoindent " Copy indent from current line when starting new line
set smartindent " Automatically insert extra indent level in some cases
set smarttab " Insert shiftwidth spaces at start of line, delete shiftwidth spaces with backspace
set expandtab " Convert tabs to spaces
set tabstop=4 " Number of spaces that a tab character displays as
set shiftwidth=2 " Number of spaces to use for each indent level
set softtabstop=2 " Number of spaces that tab key inserts
set backspace=indent,eol,start " Allow backspacing over autoindent, line breaks, and start of insert

" ============================================================
" Search Settings
" ============================================================

set hlsearch " Highlight search matches
set incsearch " Show matches as you type search pattern
set ignorecase " Case-insensitive search by default
set smartcase " Case-sensitive search if pattern contains uppercase
set gdefault " Apply substitutions globally on lines by default (add g to toggle)
set wrapscan " Wrap search around end of file
set magic " Enable extended regular expressions

" ============================================================
" Display & UI Settings
" ============================================================

set cursorline " Highlight the line containing the cursor
set nu " Show line numbers
set ruler " Show cursor position in status line
set laststatus=2 " Always show status line
set showmode " Show current mode in status line
set noshowmode " Don't show mode (status line plugin handles this)
set showtabline=2 " Always show tab bar
set title " Show filename in window titlebar
set colorcolumn=100 " Show vertical line at column 100
set linebreak " Wrap lines at word boundaries
set wrap " Enable line wrapping
set scrolloff=3 " Keep 3 lines visible above/below cursor when scrolling
set sidescrolloff=3 " Keep 3 columns visible left/right of cursor when scrolling
set visualbell " Flash screen instead of beeping
set noerrorbells " Disable error bell sounds
set mouse=a " Enable mouse support in all modes
set ttyfast " Optimize for fast terminal connection

" ============================================================
" Editing Behavior
" ============================================================

set hidden " Allow switching buffers without saving
set clipboard=unnamed,unnamedplus " Use system clipboard for yank/paste
set nostartofline " Keep cursor column when moving between lines
set nojoinspaces " Use single space after punctuation when joining lines
set history=1000 " Remember 1000 commands and search patterns

" Format options
set formatoptions= " Clear format options before setting
set formatoptions+=c " Auto-wrap comments using textwidth
set formatoptions+=r " Auto-insert comment leader after <Enter> in insert mode
set formatoptions+=o " Auto-insert comment leader after 'o' or 'O' in normal mode
set formatoptions+=q " Allow formatting comments with 'gq'
set formatoptions+=n " Recognize numbered lists when formatting
set formatoptions+=2 " Use indent of second paragraph line for rest of paragraph
set formatoptions+=l " Don't break long lines that were already long
set formatoptions+=1 " Break line before one-letter word, not after
set formatoptions+=j " Remove comment leader when joining lines

" ============================================================
" Completion & Wildmenu Settings
" ============================================================

set wildmenu " Show command-line completion matches in status line
set wildmode=list:longest " Complete to longest common string, list all matches
set wildchar=<TAB> " Character for command-line completion
set ofu=syntaxcomplete#Complete " Omni-completion function
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js " Ignore image and compiled files
set wildignore+=*/smarty/*,*/vendor/*,*/node_modules/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*,*/doc/* " Ignore common project directories
set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll " Deprioritize these file extensions in completion

" ============================================================
" Misc Settings
" ============================================================

set report=0 " Always report number of lines changed
set diffopt=filler " Add filler lines to keep text aligned in diff mode
set whichwrap+=<,>,h,l,[,] " Allow cursor keys and h/l to wrap to next/previous line

" ============================================================
" Neovim-specific Settings
" ============================================================

if has('nvim')
  set updatetime=200 " Faster update time for git signs and other plugins
  set mousemoveevent " Enable mouse move events (required for some plugins)
  set termguicolors " Enable 24-bit RGB colors in terminal
  set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20 " Cursor shape per mode (blink timing controlled by terminal)

  " Cursor shape escape sequences for terminals with incomplete terminfo (e.g., WezTerm)
  " Matches guicursor: n-v-c=block, i-ci-ve=bar, r-cr-o=underline
  lua << EOF
  local function set_cursor_shape(shape)
    io.write(string.format("\27[%d q", shape))
    io.flush()
  end

  local cursor_group = vim.api.nvim_create_augroup("TerminalCursorShape", { clear = true })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = cursor_group,
    pattern = "*",
    callback = function()
      local mode = vim.fn.mode()
      if mode:match("^i") then
        -- Insert modes: i, ic, ix (guicursor: i-ci-ve)
        set_cursor_shape(5) -- blinking bar
      elseif mode:match("^R") or mode:match("^no") then
        -- Replace: R, Rc, Rv, etc. + Operator-pending: no, nov, noV (guicursor: r-cr-o)
        set_cursor_shape(3) -- blinking underline
      else
        -- Normal, visual, select, command, etc. (guicursor: n-v-c)
        set_cursor_shape(1) -- blinking block
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeave", {
    group = cursor_group,
    callback = function() set_cursor_shape(0) end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = cursor_group,
    callback = function() set_cursor_shape(1) end,
  })
EOF
else
  set encoding=utf-8 nobomb " Use UTF-8 encoding without byte order mark (Vim only, Neovim defaults to UTF-8)
endif

" ============================================================
" Optional Features
" ============================================================

if exists('&breakindent')
  set breakindent " Indent wrapped lines to match start of line
  set showbreak=.. " String to show at start of wrapped lines
endif

if has('mouse_sgr') && !has('nvim')
  set ttymouse=sgr " Use SGR mouse protocol for better mouse support in terminals (Vim only)
endif

" NERD Commenter
let NERDSpaceDelims=1

" Latex
let g:tex_flavor = 'latex'

" vim-json
set conceallevel=2

" Vim markdown
let g:vim_markdown_folding_disabled = 1

" vim-sneak
let g:sneak#s_next = 1
let g:sneak#use_ic_scs = 1

" vim-jsx
let g:jsx_ext_required = 0

" vim-flow
let g:flow#autoclose = 1

" ============================================================
" Vim-only configuration
" ============================================================

if !has('nvim')
  " CtrlP.vim
  let g:ctrlp_match_window = 'max:50'
  let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
  let g:ctrlp_dont_split = 'NERD'
  noremap <C-h> :CtrlPBuffer<CR>
  noremap <Leader>op :CtrlPClearAllCaches<CR>

  " Airline
  if !exists('g:airline_symbols')
      let g:airline_symbols = {}
  endif

  let g:airline_theme='tomorrow'
  let g:airline#extensions#hunks#non_zero_only = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#ycm#error_symbol = 'error:'
  let g:airline#extensions#ycm#warning_symbol = 'warning:'
  let g:airline_powerline_fonts = 1
  let g:airline_symbols.branch = ''
  let g:airline_symbols.colnr = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ' :'
  let g:airline_symbols.maxlinenr = '☰ '
  let g:airline_symbols.dirty='⚡'

  " NERDTree configuration (Vim only)
  function! s:toggleNERD()
    execute 'NERDTreeToggle'
    if bufwinnr(t:NERDTreeBufName) != -1
      execute "normal \<C-w>\<C-w>"
    endif
  endfunction

  function! s:launchNERD()
    execute 'NERDTree'
    if bufwinnr(t:NERDTreeBufName) != -1
      execute "normal \<C-w>\<C-w>"
    endif
  endfunction

  let NERDTreeAutoCenterThreshold = 10
  let NERDTreeShowHidden = 1
  let NERDTreeAutoDeleteBuffer = 1
  let NERDTreeMouseMode = 2
  let NERDTreeMinimalUI = 1
  nnoremap <silent> <leader>m :call <SID>toggleNERD()<CR>
  nnoremap <silent> <leader>n :NERDTreeFind<CR>
  nnoremap <silent> <leader>b :call <SID>launchNERD()<CR>

  set pastetoggle=<Leader>u " Set paste toggle (Vim only)

  " Fugitive
  nnoremap <silent> <Leader>gl :silent Git log<CR>
  nnoremap <silent> <Leader>gb :Git blame<CR>

  " GitGutter (Vim only)
  nmap ) <Plug>GitGutterNextHunk
  nmap ( <Plug>GitGutterPrevHunk
  let g:gitgutter_realtime = 0
  let g:gitgutter_eager = 0
endif

