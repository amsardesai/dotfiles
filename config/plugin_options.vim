
" NERD Commenter
let NERDSpaceDelims=1

" CtrlP.vim
let g:ctrlp_match_window = 'max:50'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let g:ctrlp_dont_split = 'NERD'
noremap <C-h> :CtrlPBuffer<CR>
noremap <Leader>op :CtrlPClearAllCaches<CR>

" Airline
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

let g:airline_theme='tomorrow'
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ycm#error_symbol = 'error:'
let g:airline#extensions#ycm#warning_symbol = 'warning:'
let g:airline_powerline_fonts = 1
let g:airline_symbols.branch = ''
let g:airline_symbols.colnr = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ' :'
let g:airline_symbols.maxlinenr = '☰ '
let g:airline_symbols.dirty='⚡'

" Function that toggles NERDTree and switches back to the previous buffer if needed.
function! s:toggleNERD()
  execute 'NERDTreeToggle'
  if bufwinnr(t:NERDTreeBufName) != -1
    execute "normal \<C-w>\<C-w>"
  endif
endfunction

function! s:launchNERD()
  execute 'NERDTree'
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
nnoremap <silent> <leader>b :call <SID>launchNERD()<CR>

" Latex
let g:tex_flavor = 'latex'

" Fugitive
nnoremap <silent> <Leader>gl :silent Git log<CR>
nnoremap <silent> <Leader>gb :Git blame<CR>

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

" vim-jsx
let g:jsx_ext_required = 0

" vim-flow
let g:flow#autoclose = 1

" Options
set pastetoggle=<Leader>u " Set paste toggle

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
