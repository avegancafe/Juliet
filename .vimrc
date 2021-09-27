set rtp+=~/.local/share/nvim/site/pack/packer/start/LanguageClient-neovim
set encoding=UTF-8
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1

let g:DevIconsDefaultFolderOpenSymbol='' " symbol for open folder (f07c)
let g:WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol='' " symbol for closed folder (f07b)

set nocompatible
let &runtimepath.=',~/.vim/pack/user/start/neoterm'

set guifont=Pragmata\ Pro,FiraCode\ Nerd\ Font\ Mono:h18

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
set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
packadd! space-nvim
colorscheme space-nvim

nnoremap <D-1> :tabnext 1<cr>
nnoremap <D-2> :tabnext 2<cr>
nnoremap <D-3> :tabnext 3<cr>
nnoremap <D-4> :tabnext 4<cr>
nnoremap <D-5> :tabnext 5<cr>
nnoremap <D-6> :tabnext 6<cr>
nnoremap <D-7> :tabnext 7<cr>
nnoremap <D-8> :tabnext 8<cr>
nnoremap <D-9> :tabnext 9<cr>
nnoremap <D-0> :tablast<cr>
nnoremap <D-{> :tabprevious<cr>
nnoremap <D-}> :tabnext<cr>
nnoremap <D-w> :q<cr>

" Indentation
set expandtab
set shiftwidth=2
set smarttab
set softtabstop=2
set autoindent
set smartindent
set tabstop=2

" Ale
highlight clear SpellBad
highlight SpellBad cterm=underline
highlight clear ALEError
highlight ALEError cterm=underline
highlight clear ALEWarning
highlight ALEWarning cterm=underline

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

" Custom commands
function! LanguageClientRestart()
  LanguageClientStop
  sleep 500m
  LanguageClientStart
endfunction
command! LanguageClientRestart call LanguageClientRestart()

" Normal mappings
function! SynStack ()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction
map gn :call SynStack()<CR>
 
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
nnoremap <silent> <c-p> :Telescope find_files<cr>
nnoremap <silent> <c-b> :Telescope buffers<cr>
nnoremap <c-o> :w<cr>
nnoremap cq :let @*=expand("%:p")<cr>
nnoremap cw :let @*=expand("%")<cr>
nnoremap <silent> <c-f> :Goyo<cr>
" nnoremap <silent> <leader>p :!yarn prettier --write %<cr>
nnoremap <silent> <leader>f :Prettier<cr>
nnoremap <c-e> :ALEFix<cr>
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

" Insert Mappings
inoremap <c-c> <Esc>
inoremap <silent> <D-v> <c-r>*

" nvim-tree
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>

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
let g:neoterm_default_mod = 'vertical'
let g:neoterm_autoinsert = 1

" LanguageClient
let g:LanguageClient_autoStart = 1
let g:LanguageClient_usePopupHover = 1
let g:LanguageClient_hoverPreview = "Always"
let g:LanguageClient_useFloatingHover = 1
let g:LanguageClient_hideVirtualTextsOnInsert = 1

let g:LanguageClient_serverCommands = {
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ 'typescript.tsx': ['typescript-language-server', '--stdio'],
    \ 'typescriptreact': ['typescript-language-server', '--stdio'],
    \ 'ruby': ['solargraph', 'stdio'],
    \ }

augroup filetype_ts
    autocmd!
    " autocmd BufReadPost *.ts setlocal filetype=typescript
    autocmd BufNewFile,BufRead *.tsx,*.jsx,*.ts set filetype=typescriptreact syntax=typescript.tsx
augroup END

let g:neovide_cursor_vfx_mode = "pixiedust"
lua require('plugins')

