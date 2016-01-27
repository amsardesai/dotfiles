
" Sync Latex
map <silent> <localleader>ls :silent !/Applications/Skim.app/Contents/SharedSupport/displayline -r <C-r>=line(".")<CR> "<C-R>=LatexBox_GetOutputFile()<CR>" "%:p"<CR>

" LatexBox Recommended Bindings
imap <buffer> [[     \begin{
imap <buffer> ]]     <Plug>LatexCloseCurEnv
nmap <buffer> <F5>   <Plug>LatexChangeEnv
vmap <buffer> <F7>   <Plug>LatexWrapSelection
vmap <buffer> <S-F7> <Plug>LatexEnvWrapSelection
imap <buffer> ((     \eqref{

" Other stuff
set shiftwidth=2
set iskeyword+=:

" LatexBox options
let g:LatexBox_latexmk_preview_continuously = 1
let g:LatexBox_quickfix = 2
let g:LatexBox_viewer = "/Applications/Skim.app/Contents/MacOS/Skim"


" Monospace text
nmap ;;t ysiw}i\texttt<Esc>
vmap ;;t S}i\texttt<Esc>
imap ;;t \texttt{

" Bold text
nmap ;;b ysiw}i\textbf<Esc>
vmap ;;b S}i\textbf<Esc>
imap ;;b \textbf{

" Italic text
nmap ;;i ysiw}i\textit<Esc>
vmap ;;i S}i\textit<Esc>
imap ;;i \textit{

" Section with star
nmap ;;q ysiw}i\section*<Esc>
vmap ;;q S}i\section*<Esc>
imap ;;q \section*{

" Section without star
nmap ;;w ysiw}i\section<Esc>
vmap ;;w S}i\section<Esc>
imap ;;w \section{

" Itemized list
nmap ;;a o\begin{itemize}<Cr>]]<C-O>O\item<Space>
imap ;;a \begin{itemize}<Cr>]]<C-O>O\item<Space>

" Enumerated list
nmap ;;s o\begin{enumerate}<Cr>]]<C-O>O\item<Space>
imap ;;s \begin{enumerate}<Cr>]]<C-O>O\item<Space>

" Item in a list
nmap ;;z o<Backspace>\item<Space>
imap ;;z <C-O>o<Backspace>\item<Space>

" Item in a list (before)
nmap ;;Z O<Backspace>\item<Space>
imap ;;Z <C-O>O<Backspace>\item<Space>


