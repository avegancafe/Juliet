(vim.cmd "
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
         ")
