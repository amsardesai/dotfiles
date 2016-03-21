
" NERD Commenter
let NERDSpaceDelims=1

" CtrlP.vim
let g:ctrlp_match_window = 'max:50'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let g:ctrlp_dont_split = 'NERD'
noremap <C-h> :CtrlPBuffer<CR>
noremap <Leader>op :CtrlPClearAllCaches<CR>

" Airline
let g:airline_theme='tomorrow'
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ycm#error_symbol = 'error:'
let g:airline#extensions#ycm#warning_symbol = 'warning:'
let g:airline_powerline_fonts = 1

" NERDTree

" Function that toggles NERDTree and switches back to the previous buffer if
" needed.
function! s:toggleNERD()
  execute 'NERDTreeToggle'
  if bufwinnr(t:NERDTreeBufName) != -1
    execute "normal \<C-w>\<C-w>"
  endif
endfunction

let NERDTreeAutoCenterThreshold = 10
let NERDTreeShowHidden = 1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMouseMode = 2
let NERDTreeMinimalUI = 1
nnoremap <silent> <leader>m :call <SID>toggleNERD()<CR>
nnoremap <silent> <leader>n :NERDTreeFind<CR>
nnoremap <silent> <leader>b :NERDTree<CR><C-w>w

" Latex
let g:tex_flavor = 'latex'

" Fugitive
nnoremap <silent> <Leader>gl :silent Glog<CR>
nnoremap <silent> <Leader>gb :Gblame<CR>

" vim-json
set conceallevel=2

" Vim markdown
let g:vim_markdown_folding_disabled = 1

" GitGutter
nmap ) <Plug>GitGutterNextHunk
nmap ( <Plug>GitGutterPrevHunk

" vim-sneak
let g:sneak#s_next = 1
let g:sneak#use_ic_scs = 1

if has('nvim')
  " Neovim specific commands

  " Function to check if whitespace exists
  function! s:is_whitespace() "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~? '\s'
  endfunction

  " Deoplete
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#file#enable_buffer_path = 1

  " Key bindings for completion for deoplete
  inoremap <silent> <expr> <Tab> pumvisible() ? "\<C-n>" :
      \ (<SID>is_whitespace() ? "\<Tab>" : deoplete#mappings#manual_complete())
  inoremap <silent> <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
  inoremap <silent> <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
  inoremap <silent> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"

  " Tern for vim
  autocmd FileType javascript setlocal omnifunc=tern#Complete
  let g:tern_show_signature_in_pum = 1

  " Neomake
  let g:neomake_javascript_enabled_makers = ['eslint']
  autocmd! BufWritePost * Neomake
  hi NeomakeError cterm=underline ctermfg=167 ctermbg=52 gui=undercurl
  hi NeomakeWarning cterm=underline ctermfg=172 ctermbg=58 gui=undercurl
  let g:neomake_error_sign = { 'text': '!>', 'texthl': 'NeomakeError' }
  let g:neomake_warning_sign = { 'text': '!>', 'texthl': 'NeomakeWarning' }

  " vim-grepper
  nnoremap <Leader>gk :Grepper -tool git -switch<CR>
  vnoremap <Leader>gk :Grepper -tool git -cword -switch<CR>

else
  " Old vim specific commands

  " Options
  set pastetoggle=<Leader>u " Set paste toggle

  " UtiliSnips
  let g:UltiSnipsExpandTrigger = '<C-j>'
  let g:UltiSnipsJumpForwardTrigger = '<C-b>'
  let g:UltiSnipsJumpBackwardTrigger = '<C-z>'

  " YouCompleteMe
  let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
  let g:ycm_path_to_python_interpreter = '/usr/bin/python'
  let g:ycm_confirm_extra_conf = 0

  " Syntastic
  let b:syntastic_mode = 'passive'
  let g:syntastic_enable_signs = 1
  let g:syntastic_javascript_checkers = ['eslint']
  nnoremap <Leader>sk :SyntasticToggleMode<CR>
  nnoremap <Leader>sr :SyntasticReset<CR>
  nnoremap <Leader>si :SyntasticInfo<CR>
  nnoremap <Leader>sc :SyntasticCheck<CR>

  " GitGutter
  let g:gitgutter_realtime = 0
  let g:gitgutter_eager = 0

endif
