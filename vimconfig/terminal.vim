" Terminal utility keybindings
" Note: ,z and ,x are handled by snacks.nvim in plugin_options.vim (Neovim)
" These Vimscript mappings are kept as fallback for Vim

if !has('nvim')
  " Vim-only: basic terminal open/close
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

" Buffer navigation (,]) (,[)
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


