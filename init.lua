vim.opt.runtimepath = vim.opt.runtimepath + ',~/.local/share/nvim/site/pack/packer/start/LanguageClient-neovim'
vim.opt.encoding = 'UTF-8'

vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
vim.g.DevIconsEnableFoldersOpenClose = 1
vim.g.startify_change_to_vcs_root = 1
vim.g.DevIconsDefaultFolderOpenSymbol = ''
vim.g.WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = ''

vim.opt.runtimepath = vim.opt.runtimepath + ',~/.vim/pack/user/start/neoterm'

vim.opt.guifont = 'Pragmata Pro, FiraCode Nerd Font Mono:h18'

vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

vim.opt.mouse = 'a'
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 3
vim.cmd('hi Directory guifg=#FF0000 ctermfg=red')
vim.opt.backspace = 'indent,eol,start'
vim.opt.clipboard = 'unnamed'
vim.opt.shell = 'fish'
vim.opt.fdm = 'syntax'
vim.opt.foldlevelstart = 20
vim.cmd('autocmd InsertEnter * set cursorline')
vim.cmd('autocmd InsertLeave * set nocursorline')

-- theme
vim.opt.termguicolors = true
vim.cmd('colorscheme void')

-- indentation
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.cmd([[
augroup FiletypeGroup
    autocmd!
    au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
    au BufNewFile,BufRead *.mdx set filetype=markdown.mdx
    au BufRead,BufNewFile *.md setlocal textwidth=80
    au FileType fish compiler fish
    au FileType fish setlocal textwidth=79
    au FileType fish setlocal foldmethod=expr
augroup END
]])

vim.cmd('highlight MatchParen cterm=bold ctermfg=white ctermbg=black')

require('plugins')
require('mappings')
require('initializers.index')
