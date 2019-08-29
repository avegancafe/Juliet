set rtp+=/usr/local/opt/fzf
" Defaults
filetype on
filetype plugin on
filetype indent on
syntax on
set mouse=a
set relativenumber
set number
set numberwidth=3
hi Directory guifg=#FF0000 ctermfg=red
set backspace=indent,eol,start
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
set clipboard=unnamed
set shell=bash
set fdm=syntax
set foldlevelstart=20
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
autocmd InsertEnter * set cul
autocmd InsertLeave * set nocul

" Indentation
set expandtab
set shiftwidth=2
set smarttab
set softtabstop=2
set autoindent
set smartindent
set tabstop=2

" Neoformat
" let g:neoformat_javascript_prettier = {
"   \ 'exe': 'prettier',
"   \ 'args': [
"   \   '--semi',
"   \   '--print-width 100',
"   \   '--arrow-parens always',
"   \   '--trailing-comma es5',
"   \   '--single-quote',
"   \ ],
"   \}
" let g:neoformat_javascript_prettier = {
"   \ 'exe': 'prettier',
"   \ 'args': [
"   \   '--trailing-comma es5',
"   \   '--no-semi',
"   \   '--single-quote',
"   \   '--print-width 80',
"   \ ],
"   \}
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_try_formatprg = 1
" Ale
let g:ale_fixers = {
\   'javascript': ['prettier'],
\}
let g:ale_linters = {
  \'javascript': ['eslint'],
  \'jsx': ['eslint']
\}
augroup FiletypeGroup
    autocmd!
    au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
augroup END

highlight MatchParen cterm=bold ctermfg=white ctermbg=black

" Normal mappings
nnoremap K <nop>
nnoremap <leader>ev :tabe $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>' viw<esc>a"<esc>bi"<esc>el
nnoremap H ^
nnoremap L g$
nnoremap q: <nop>
nnoremap <leader>d :g/;;/d<cr>
nnoremap <silent> <leader>l :exec &number == 0 ? "set number norelativenumber" : "set relativenumber nonumber"<cr>
nnoremap <silent> <c-p> :GFiles<cr>
nnoremap <silent> <c-b> :Buffers<cr>
nnoremap <c-o> :w<cr>
nnoremap cq :let @*=expand("%:p")<cr>
nnoremap cw :let @*=expand("%")<cr>
nnoremap <silent> <c-g> :FZFMru<cr>
nnoremap <silent> <c-f> :Goyo<cr>
nnoremap <silent> <c-h> <c-w>h
nnoremap <silent> <leader>f :Neoformat<cr>
nnoremap <leader>s :call RunNearestSpec()<cr>
nnoremap <c-e> :ALEFix<cr>
command! -bang -nargs=? -complete=dir GFiles
  \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)
" nmap <silent> <leader>l ?function<cr>:noh<cr><Plug>(jsdoc)
" nmap <silent> <leader>d <Plug>(jsdoc)

if has("nvim")
  " tnoremap <esc> <c-\><c-n>
  tnoremap <c-[> <c-\><c-n>
endif

let g:jsdoc_allow_input_prompt = 1
let g:jsdoc_enable_es6=1

" Command mappings
cnoreabbrev X x
cnoreabbrev gist Gist
cnoreabbrev lc lclose
cnoreabbrev lo lopen
cnoreabbrev qf q!
cnoreabbrev ag Ag

" Insert Mappings
inoremap <c-c> <Esc>

" NERDtree
nmap <c-n> :NERDTreeToggle<cr>
nmap <c-l> :NERDTreeFind<cr>

" airline
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
set laststatus=2
set t_Co=256
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
end
let g:airline_left_sep = ''
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_right_sep = ''
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'
let g:loaded_airline_themes = 1
let g:airline_theme='minimalist'
let g:airline#extensions#tabline#formatter = 'unique_tail'

let g:quantum_italics = 1

map <esc><esc> :w<cr>

" loupe
nmap <leader>x <Plug>(LoupeClearHighlight)

" lexima.vim
let g:lexima_enable_basic_rules = 1
let g:lexima_enable_newline_rules = 1
let g:lexima_enable_endwise_rules = 1

" goyo.vim
let g:goyo_width = 100
set rtp+='~/.opam/4.06.1/share/merlin/vim'

" comittia
let g:committia_hooks = {}
function! g:committia_hooks.edit_open(info)
    setlocal spell
    if a:info.vcs ==# 'git' && getline(1) ==# ''
        startinsert
    end
    imap <buffer><c-n> <Plug>(committia-scroll-diff-down-half)
    imap <buffer><c-u> <Plug>(committia-scroll-diff-up-half)
    nmap <buffer><c-n> <Plug>(committia-scroll-diff-down-half)
    nmap <buffer><c-u> <Plug>(committia-scroll-diff-up-half)
endfunction
" gist.vim
let g:gist_show_privates = 1
