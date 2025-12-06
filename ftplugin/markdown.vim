" Markdown-specific settings
" Soft wrapping for comfortable reading of long lines

" Soft wrap long lines at window edge
setlocal wrap

" Wrap at word boundaries, not mid-word
setlocal linebreak

" Preserve indentation on wrapped lines
setlocal breakindent

" Show wrapped line continuation indicator
setlocal showbreak=↪\

" Navigate by display lines (not file lines) with j/k
nnoremap <buffer> j gj
nnoremap <buffer> k gk

" Don't show colorcolumn (looks weird with soft wrap)
setlocal colorcolumn=

" Wider text width for gq formatting
setlocal textwidth=100
