
" Install plug if it's not already installed
if empty(glob(g:base_actual_vim_dir . 'autoload/plug.vim'))
  execute '!mkdir -p ' . g:base_actual_vim_dir . 'autoload/'
  execute '!mkdir -p ' . g:base_actual_vim_dir . 'backups/'
  execute '!mkdir -p ' . g:base_actual_vim_dir . 'bundle/'
  execute '!mkdir -p ' . g:base_actual_vim_dir . 'swaps/'
  execute '!mkdir -p ' . g:base_actual_vim_dir . 'undo/'
  execute '!curl -fLo ' . g:base_actual_vim_dir . 'autoload/plug.vim --create-dirs ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

