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

(vim.cmd "set scrolloff=4")
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
(if (= (vim.fn.exists "g:neovide") 1)
    (do
      (set vim.opt.guifont "Iosevka Nerd Font Mono:h14")
      (set vim.g.neovide_padding_top 8)
      (set vim.g.neovide_padding_bottom 4)
      (set vim.g.neovide_opacity 0.97)
      (set vim.g.neovide_floating_shadow false)
      (set vim.g.neovide_input_macos_option_key_is_meta :only_left)
      (vim.cmd "let g:neovide_cursor_trail_size = 0.2")
      (vim.cmd "let g:neovide_cursor_animate_command_line = v:false"))
    (set vim.opt.guifont "Iosevka Nerd Font Mono:h19"))

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
(vim.cmd "set sessionoptions-=folds")
(vim.cmd "set noshowmode")
(set vim.opt.termguicolors true)
(set vim.opt.shiftwidth 2)
(set vim.opt.softtabstop 2)
(set vim.opt.tabstop 2)
(set vim.opt.hidden true)
(vim.cmd "augroup FiletypeGroup
  autocmd!
  autocmd BufNewFile,BufRead *.jsx set filetype=javascript.jsx
  autocmd BufNewFile,BufRead *.sql set filetype=jinja
  autocmd BufNewFile,BufRead *.mdx set filetype=markdown.mdx
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80
  autocmd BufNewFile,BufRead Brewfile set filetype=ruby
  autocmd BufNewFile,BufRead Procfile set filetype=sh
augroup END
")

(vim.api.nvim_create_autocmd :FileType
                             {:callback (fn []
                                          (vim.treesitter.start))
                              :pattern [:js
                                        :jsx
                                        :ts
                                        :tsx
                                        :typescript
                                        :typescriptreact
                                        :javascript
                                        :py
                                        :python
                                        :lua
                                        :fnl
                                        :fennel
                                        :go
                                        :rs
                                        :rb
                                        :java
                                        :c
                                        :html
                                        :css
                                        :scss
                                        :json
                                        :json5
                                        :toml
                                        :yaml
                                        :yml
                                        :md
                                        :lua
                                        :fish
                                        :bash
                                        :Dockerfile
                                        :http
                                        :makefile
                                        :proto
                                        :regex
                                        :svelte
                                        :swift
                                        :sql]})

(vim.cmd "highlight MatchParen cterm=bold ctermfg=white ctermbg=black")
