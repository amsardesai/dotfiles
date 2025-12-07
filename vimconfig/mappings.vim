
" Disable Ex mode
nnoremap Q <nop>
nnoremap gQ <nop>

" Escape to remove search results
nnoremap <silent> <CR> :noh<CR><CR>

" Brackets for easier page movement
nnoremap _ <C-b>
nnoremap + <C-f>
vnoremap _ <C-b>
vnoremap + <C-f>

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
nnoremap <Leader>q :cclose<CR>:pclose<CR>:lclose<CR>

" Redraw screen if something weird happens
nnoremap <Leader>rd :redraw!<CR>

" Re-source this file
nnoremap <Leader>rs :source $MYVIMRC<CR>

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
  nnoremap <Leader>gh :e %:p:s,.h$,.X123X,:s,.cc$,.h,:s,.X123X$,.cc,<CR>
endif

" Ruby
au BufRead,BufNewFile Rakefile,Capfile,Gemfile,.autotest,.irbrc,*.treetop,*.tt set ft=ruby

" JSON
au BufRead,BufNewFile .jshintrc,.eslintrc set ft=json

" Map BehaveZZ
map ZZ :call BehaveZZ()<CR>

" =============================================================================
" Terminal mappings (if terminal support exists)
" =============================================================================
if exists(':terminal')
  " Vim-only: basic terminal open/close
  " Note: Neovim uses snacks.nvim for ,z and ,x
  if !has('nvim')
    nnoremap <Leader>z :below terminal<CR>
    nnoremap <Leader>x :bd!<CR>
  endif

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
  tnoremap <C-w><C-w> <C-\><C-n><C-w><C-w>

  " Re-source this file
  tnoremap <Leader>rs <C-\><C-n>:source $MYVIMRC<CR>

  " Buffer navigation
  tnoremap <Leader>, <C-\><C-n><C-^>
  tnoremap <Leader>] <C-\><C-n>:bnext<CR>
  tnoremap <Leader>[ <C-\><C-n>:bprevious<CR>
  tnoremap <Leader>\ <C-\><C-n>:bprevious<CR><C-\><C-n>:bdelete<SPACE>#<CR>
  tnoremap <Leader><bar> <C-\><C-n>:bprevious<CR><C-\><C-n>:bdelete!<SPACE>#<CR>
  tnoremap <Leader>ls <C-\><C-n>:buffers<CR>

  " Redraw screen if something weird happens
  tnoremap <Leader>rd <C-\><C-n>:redraw!<CR>

  " Insert on enter, normal on leave
  autocmd BufWinEnter,WinEnter term://* startinsert
  autocmd BufLeave term://* stopinsert
endif
