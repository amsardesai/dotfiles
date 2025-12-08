
" ============================================================
" Vim/Neovim Installation & Directory Setup
" ============================================================
" This file handles initial setup for both Vim and Neovim:
" - Creates necessary directories (backups, swaps, undo, plugins)
" - Installs vim-plug plugin manager if not present
" - Configures directory paths for each editor separately
" ============================================================

" ============================================================
" Directory Path Configuration
" ============================================================

if has('nvim')
  " Neovim: Use XDG state directory (default location for runtime state files)
  let s:backup_dir = stdpath('state') . '/backup'
  let s:swap_dir = stdpath('state') . '/swap'
  let s:undo_dir = stdpath('state') . '/undo'
  let s:view_dir = stdpath('state') . '/view'
else
  " Vim: Use ~/.vim directory (traditional vim default)
  let s:backup_dir = '~/.vim/backup'
  let s:swap_dir = '~/.vim/swap'
  let s:undo_dir = '~/.vim/undo'
  let s:view_dir = '~/.vim/view'
endif

" ============================================================
" Create Required Directories
" ============================================================

" Create backup, swap, undo, and view directories
if !isdirectory(expand(s:backup_dir))
  call mkdir(expand(s:backup_dir), 'p')
endif
if !isdirectory(expand(s:swap_dir))
  call mkdir(expand(s:swap_dir), 'p')
endif
if !isdirectory(expand(s:undo_dir))
  call mkdir(expand(s:undo_dir), 'p')
endif
if !isdirectory(expand(s:view_dir))
  call mkdir(expand(s:view_dir), 'p')
endif

" Configure Vim/Neovim to use these directories
" // suffix encodes full file path in filenames to prevent collisions
execute 'set backupdir=' . s:backup_dir . '//'
execute 'set directory=' . s:swap_dir . '//'
execute 'set undodir=' . s:undo_dir . '//'
execute 'set viewdir=' . s:view_dir . '//'

" ============================================================
" Vim-Plug Plugin Manager Installation (Vim only)
" ============================================================
" Neovim uses lazy.nvim instead

if !has('nvim')
  let autoload_plug_path = '~/.vim/autoload/plug.vim'
  let s:plugin_dir = '~/.vim/bundle'

  " Install vim-plug if not present
  if empty(glob(autoload_plug_path))
    " Create autoload directory
    let l:autoload_dir = fnamemodify(autoload_plug_path, ':h')
    if !isdirectory(expand(l:autoload_dir))
      call mkdir(expand(l:autoload_dir), 'p')
    endif

    " Create plugin directory
    if !isdirectory(expand(s:plugin_dir))
      call mkdir(expand(s:plugin_dir), 'p')
    endif

    " Download vim-plug
    execute '!curl -fLo ' . autoload_plug_path . ' --create-dirs ' .
          \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    " Auto-install plugins on first launch
    autocmd VimEnter * PlugInstall | source $MYVIMRC
  endif
endif
