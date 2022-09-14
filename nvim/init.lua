vim.opt.encoding = "UTF-8"
vim.cmd("set noswapfile")
vim.opt.switchbuf = "uselast"
vim.cmd([[
augroup quickfix
  autocmd!
  au FileType qf wincmd J
augroup END
]])

vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
vim.g.DevIconsEnableFoldersOpenClose = 1
vim.g.startify_change_to_vcs_root = 1
vim.g.DevIconsDefaultFolderOpenSymbol = ""
vim.g.WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = ""
vim.g.indentLine_fileTypeExclude = { "dashboard", "packer" }
vim.g.go_fmt_command = "goimports"
-- vim.lsp.set_log_level("debug")
vim.opt.timeoutlen = 500
-- vim.g.ale_go_golangci_lint_options = "--config ~/workspace/api-v2-backend/.build/scripts/.golangci.yml"
vim.g.dbext_default_profile_myPSQL = "user=kyle"
vim.opt.guifont = "JetBrainsMono Nerd Font Mono:h18"

vim.cmd("filetype plugin indent on")

vim.opt.mouse = "a"
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 3
vim.cmd("hi Directory guifg=#FF0000 ctermfg=red")
vim.opt.backspace = "indent,eol,start"
vim.opt.clipboard = "unnamed"
vim.opt.shell = "fish"
vim.opt.fdm = "syntax"
vim.opt.foldlevelstart = 20
vim.cmd("autocmd InsertEnter * set cursorline")
vim.cmd("autocmd InsertLeave * set nocursorline")
vim.cmd("set completeopt-=preview")
vim.cmd("set noshowmode")

-- theme
vim.opt.termguicolors = true

-- indentation
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.foldmethod = "indent"

vim.opt.hidden = true

vim.cmd([[
augroup FiletypeGroup
  autocmd!
  au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
  au BufNewFile,BufRead *.mdx set filetype=markdown.mdx
  au BufRead,BufNewFile *.md setlocal textwidth=80
  au FileType fish setlocal textwidth=79
  au FileType fish setlocal foldmethod=expr
  autocmd BufNewFile,BufRead Brewfile set filetype=ruby
augroup END
]])

vim.cmd("highlight MatchParen cterm=bold ctermfg=white ctermbg=black")
-- vim.cmd('source ~/.config/Juliet/nvim/_init.vim')

require("plugins")
require("mappings")
require("initializers.index")
