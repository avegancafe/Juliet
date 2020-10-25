set rtp+=/usr/local/opt/fzf
set rtp+=~/.vim/pack/user/start/LanguageClient-neovim
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set nocompatible
let &runtimepath.=',~/.vim/pack/user/start/neoterm'

" Defaults
syntax enable
filetype plugin indent on
set mouse=a
set relativenumber
set noswapfile
set number
set numberwidth=3
hi Directory guifg=#FF0000 ctermfg=red
set backspace=indent,eol,start
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
set clipboard=unnamed
set shell=fish
set fdm=syntax
set foldlevelstart=20
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
autocmd InsertEnter * set cul
autocmd InsertLeave * set nocul

" theme
" if (has("termguicolors"))
"   set termguicolors
" endif
if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif
colorscheme material

" Indentation
set expandtab
set shiftwidth=2
set smarttab
set softtabstop=2
set autoindent
set smartindent
set tabstop=2

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
    au BufNewFile,BufRead *.mdx set filetype=markdown.mdx
    au BufRead,BufNewFile *.md setlocal textwidth=80
    au FileType fish compiler fish
    au FileType fish setlocal textwidth=79
    au FileType fish setlocal foldmethod=expr
augroup END

highlight MatchParen cterm=bold ctermfg=white ctermbg=black

let g:fzf_command_prefix = 'Fzf'

" Normal mappings
map t<leader>f :TestFile<cr>
map t<leader>l :TestLast<cr>

map <leader>t :Tnew<cr>

nmap <silent> K <Plug>(lcn-menu)
nnoremap <leader>ev :tabe $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" nnoremap <leader>t :put =strftime('%FT%T%z')<cr>
" nmap <leader>t a<C-R>=strftime("%Y-%m-%d")<CR><Esc>
nnoremap <leader>' viw<esc>a"<esc>bi"<esc>el
nnoremap H ^
nnoremap L g$
nnoremap q: <nop>
nnoremap <leader>d :g/;;/d<cr>
nnoremap <silent> <leader>l :exec &number == 0 ? "set number norelativenumber" : "set relativenumber nonumber"<cr>
nnoremap <silent> <c-p> :FzfFiles<cr>
nnoremap <silent> <c-b> :FzfBuffers<cr>
nnoremap <c-o> :w<cr>
nnoremap cq :let @*=expand("%:p")<cr>
nnoremap cw :let @*=expand("%")<cr>
nnoremap <silent> <c-g> :FzfHistory<cr>
nnoremap <silent> <c-f> :Goyo<cr>
nnoremap <silent> <c-h> <c-w>h
" nnoremap <silent> <leader>p :!yarn prettier --write %<cr>
nnoremap <silent> <leader>f :Prettier<cr>
nnoremap <c-e> :ALEFix<cr>
command! -bang -nargs=? -complete=dir FzfFiles
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--margin=1,4']}), <bang>0)
" nmap <silent> <leader>l ?function<cr>:noh<cr><Plug>(jsdoc)
" nmap <silent> <leader>d <Plug>(jsdoc)

" Make ci( work like quotes do
function! New_cib()
    if search("(","bn") == line(".")
        sil exe "normal! f)ci("
        sil exe "normal! l"
        startinsert
    else
        sil exe "normal! f(ci("
        sil exe "normal! l"
        startinsert
    endif
endfunction

" And for curly brackets
function! New_ciB()
    if search("{","bn") == line(".")
        sil exe "normal! f}ci{"
        sil exe "normal! l"
        startinsert
    else
        sil exe "normal! f{ci{"
        sil exe "normal! l"
        startinsert
    endif
endfunction

nnoremap ci( :call New_cib()<CR>
nnoremap cib :call New_cib()<CR>
nnoremap ci{ :call New_ciB()<CR>
nnoremap ciB :call New_ciB()<CR>

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
cnoreabbrev ag FzfAg

" Insert Mappings
inoremap <c-c> <Esc>

" NERDtree
nnoremap <c-n> :NERDTree<cr>
nnoremap <c-m> :NERDTreeClose<cr>
nnoremap <c-\> :NERDTreeFind<cr>

" airline
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_buffers = 0
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

" indentLines
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" rspec
let g:rspec_command = "!bundle exec rspec --drb {spec}"

" vim-test
let test#strategy = "neoterm"
let g:neoterm_default_mod = 'rightbelow'
let g:neoterm_autoinsert = 1

" LanguageClient
let g:LanguageClient_autoStart = 1
let g:LanguageClient_selectionUI = "fzf"
let g:LanguageClient_usePopupHover = 1
let g:LanguageClient_hoverPreview = "Always"
let g:LanguageClient_useFloatingHover = 1

let g:LanguageClient_serverCommands = {
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ 'typescript.tsx': ['typescript-language-server', '--stdio'],
    \ 'typescriptreact': ['typescript-language-server', '--stdio'],
    \ 'ruby': ['solargraph', 'stdio'],
    \ }
augroup filetype_ts
    autocmd!
    autocmd BufReadPost *.ts setlocal filetype=typescript
    autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact syntax=typescript.tsx
augroup END

source ~/.vim/statusline.vim
