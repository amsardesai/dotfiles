
" Install plug if it's not already installed
if has('nvim')
  let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
else
  let autoload_plug_path = $VIMPATH . 'autoload/plug.vim'
endif

if empty(glob(autoload_plug_path))
  if has('nvim')
    execute '!mkdir -p ' . stdpath('data') . '/site/autoload/'
  else
    execute '!mkdir -p ' . $VIMPATH . 'autoload/'
  endif
  execute '!mkdir -p ' . $VIMPATH . 'backups/'
  execute '!mkdir -p ' . $VIMPATH . 'bundle/'
  execute '!mkdir -p ' . $VIMPATH . 'swaps/'
  execute '!mkdir -p ' . $VIMPATH . 'undo/'
  execute '!curl -fLo ' . autoload_plug_path . ' --create-dirs ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

