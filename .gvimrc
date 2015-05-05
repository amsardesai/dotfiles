set guifont=Monaco\ for\ Powerline:h11
set guioptions-=r
set guioptions-=L
set guioptions-=e

" Better pane switching (for MacVim)
nnoremap <silent> <D-S-Right> <c-w>l
nnoremap <silent> <D-S-Left> <c-w>h
nnoremap <silent> <D-S-Up> <c-w>k
nnoremap <silent> <D-S-Down> <c-w>j
inoremap <silent> <D-S-Right> <c-o><c-w>l
inoremap <silent> <D-S-Left> <c-o><c-w>h
inoremap <silent> <D-S-Up> <c-o><c-w>k
inoremap <silent> <D-S-Down> <c-o><c-w>j

" Better tab switching
nnoremap <silent> <D-A-Left> gT
nnoremap <silent> <D-A-Right> gt
inoremap <silent> <D-A-Left> <c-o>gT
inoremap <silent> <D-A-Right> <c-o>gt

