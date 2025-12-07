
" Make vim more useful
if exists('&nocompatible')
  set nocompatible
endif

let $VIMCONFIG = expand('<sfile>:p:h')

" Set VIMPATH based on editor
if has('nvim')
  let $VIMPATH = stdpath('data') . '/'
else
  let $VIMPATH = '~/.vim/'
endif

" Sourcing function
function! s:source_file(path) abort
  execute 'source' fnameescape($VIMCONFIG . '/' . a:path)
endfunction

" Functions
call s:source_file('helpers/behave_zz.vim')


" Core
" Skip vim-plug for Neovim (it uses lazy.nvim from nvim/plugins.lua)
if !has('nvim')
  call s:source_file('install.vim')
  call s:source_file('plugins.vim')
  call s:source_file('mappings.vim')
endif
call s:source_file('options.vim')
