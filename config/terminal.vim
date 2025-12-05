
" Function to toggle terminal in horizontal split at 30% height
function! s:openTerminalSplit()
  " Check if we're currently in a terminal buffer
  if &buftype == 'terminal'
    " Go back to previous window
    wincmd p
    return
  endif

  " Look for existing terminal window
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&buftype') == 'terminal'
      " Found terminal window, switch to it
      execute winnr . 'wincmd w'
      startinsert
      return
    endif
  endfor

  " No terminal found, create new one
  let l:height = &lines * 30 / 100
  execute 'below ' . l:height . 'split'
  terminal
  startinsert
endfunction

" Function to close terminal and return to editor
function! s:closeTerminal()
  " Check if we're currently in a terminal buffer
  if &buftype == 'terminal'
    " Close the terminal buffer (also closes the window)
    bd!
    return
  endif

  " Look for existing terminal window and close it
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&buftype') == 'terminal'
      " Found terminal window, get its buffer number and delete it
      let l:termbuf = winbufnr(winnr)
      execute 'bd! ' . l:termbuf
      return
    endif
  endfor
endfunction

nnoremap <Leader>z :call <SID>openTerminalSplit()<CR>
nnoremap <Leader>x :call <SID>closeTerminal()<CR>
vnoremap <Leader>z :<C-u>call <SID>openTerminalSplit()<CR>
vnoremap <Leader>x :<C-u>call <SID>closeTerminal()<CR>
tnoremap <Leader>z <C-\><C-n>:call <SID>openTerminalSplit()<CR>
tnoremap <Leader>x <C-\><C-n>:call <SID>closeTerminal()<CR>

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


