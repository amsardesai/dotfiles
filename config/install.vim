
" Install plug if it's not already installed
if empty(glob($VIMPATH . 'autoload/plug.vim'))
  execute '!mkdir -p ' . $VIMPATH . 'autoload/'
  execute '!mkdir -p ' . $VIMPATH . 'backups/'
  execute '!mkdir -p ' . $VIMPATH . 'bundle/'
  execute '!mkdir -p ' . $VIMPATH . 'swaps/'
  execute '!mkdir -p ' . $VIMPATH . 'undo/'
  execute '!curl -fLo ' . $VIMPATH . 'autoload/plug.vim --create-dirs ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

