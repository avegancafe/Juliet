(set vim.g.mapleader " ")
(set vim.opt.encoding :UTF-8)
(vim.cmd "set noswapfile")
(vim.cmd "set ignorecase")
(set vim.opt.switchbuf :uselast)
(set vim.opt.diffopt (+ vim.opt.diffopt "linematch:60"))
(vim.cmd "augroup quickfix
         autocmd!
         au FileType qf wincmd J
         augroup END")

(vim.cmd "set scrolloff=4\n")
(set vim.g.omni_sql_no_default_maps 1)
(set vim.g.loaded_netrw 1)
(set vim.g.loaded_netrwPlugin 1)
(set vim.g.shortmess "")
(set vim.g.WebDevIconsUnicodeDecorateFolderNodes 1)
(set vim.g.DevIconsEnableFoldersOpenClose 1)
(set vim.g.DevIconsDefaultFolderOpenSymbol "")
(set vim.g.WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol "")
(set vim.g.go_fmt_command :goimports)
(set vim.opt.timeoutlen 500)
(set vim.opt.guifont "Iosevka Nerd Font Mono:h19")
(vim.cmd "filetype off")
(vim.cmd "filetype plugin on")
(vim.cmd "filetype plugin indent on")
(set vim.opt.mouse :a)
(set vim.opt.mousemoveevent true)
(set vim.opt.number true)
(set vim.opt.relativenumber true)
(set vim.opt.numberwidth 3)
(set vim.opt.backspace "indent,eol,start")
(set vim.opt.clipboard :unnamed)
(set vim.opt.shell :fish)
(set vim.opt.fdm :syntax)
(set vim.opt.cursorline true)
(vim.cmd "set completeopt-=preview")
(vim.cmd "set noshowmode")
(set vim.opt.termguicolors true)
(set vim.opt.shiftwidth 2)
(set vim.opt.softtabstop 2)
(set vim.opt.tabstop 2)
(set vim.opt.foldmethod :expr)
(set vim.opt.foldlevelstart 99)
(set vim.opt.hidden true)
(vim.cmd "augroup FiletypeGroup
  autocmd!
  au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
  au BufNewFile,BufRead *.mdx set filetype=markdown.mdx
  au BufRead,BufNewFile *.md setlocal textwidth=80
  autocmd BufNewFile,BufRead Brewfile set filetype=ruby
  autocmd BufNewFile,BufRead Procfile set filetype=sh
augroup END
")

(set vim.opt.updatetime (* 1000 30))

(vim.cmd "
augroup Screensaver
  autocmd!
  autocmd CursorHold * :CellularAutomaton game_of_life
augroup END
")

(vim.cmd "highlight MatchParen cterm=bold ctermfg=white ctermbg=black")
