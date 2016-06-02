
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
nmap <localleader>t ysiw}i\texttt<C-[>
vmap <localleader>t S}i\texttt<C-[>
imap <localleader>t \texttt{

" Bold text
nmap <localleader>b ysiw}i\textbf<C-[>
vmap <localleader>b S}i\textbf<C-[>
imap <localleader>b \textbf{

" Italic text
nmap <localleader>i ysiw}i\textit<C-[>
vmap <localleader>i S}i\textit<C-[>
imap <localleader>i \textit{

" Section with star
nmap <localleader>q ysiw}i\section*<C-[>
vmap <localleader>q S}i\section*<C-[>
imap <localleader>q \section*{

" Section without star
nmap <localleader>w ysiw}i\section<C-[>
vmap <localleader>w S}i\section<C-[>
imap <localleader>w \section{

" Itemized list
nmap <localleader>a o\begin{itemize}<Cr>]]<C-O>O\item<Space>
imap <localleader>a \begin{itemize}<Cr>]]<C-O>O\item<Space>

" Enumerated list
nmap <localleader>s o\begin{enumerate}<Cr>]]<C-O>O\item<Space>
imap <localleader>s \begin{enumerate}<Cr>]]<C-O>O\item<Space>

" Item in a list
nmap <localleader>z o<Backspace>\item<Space>
imap <localleader>z <C-O>o<Backspace>\item<Space>

" Item in a list (before)
nmap <localleader>Z O<Backspace>\item<Space>
imap <localleader>Z <C-O>O<Backspace>\item<Space>


