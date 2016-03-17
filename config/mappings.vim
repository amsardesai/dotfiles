
" Speed up transition from modes
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
  augroup END
endif

" Disable Ex mode
nnoremap Q <nop>
nnoremap gQ <nop>

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
noremap <Leader>q :cclose<CR>:pclose<CR>:lclose<CR>

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

" Map BehaveZZ
map ZZ :call BehaveZZ()<CR>

