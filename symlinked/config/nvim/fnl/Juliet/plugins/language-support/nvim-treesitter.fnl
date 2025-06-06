(import-macros {: pack} :Juliet.macros)

(pack :nvim-treesitter/nvim-treesitter
      {:build ":TSUpdate"
       :config (fn []
                 (vim.api.nvim_create_autocmd [:BufEnter
                                               :BufAdd
                                               :BufNew
                                               :BufNewFile
                                               :BufWinEnter]
                                              {:group (vim.api.nvim_create_augroup :TS_FOLD_WORKAROUND
                                                                                   {})
                                               :callback (fn []
                                                           (tset vim.opt
                                                                 :foldmethod
                                                                 :expr)
                                                           (tset vim.opt
                                                                 :foldexpr
                                                                 "nvim_treesitter#foldexpr()"))})
                 ((. (require :nvim-treesitter.configs) :setup) {:ensure_installed [:bash
                                                                                    :cmake
                                                                                    :comment
                                                                                    :css
                                                                                    :dockerfile
                                                                                    :fennel
                                                                                    :fish
                                                                                    :gitignore
                                                                                    :go
                                                                                    :gomod
                                                                                    :graphql
                                                                                    :html
                                                                                    :http
                                                                                    :javascript
                                                                                    :jinja
                                                                                    :jsdoc
                                                                                    :json5
                                                                                    :json
                                                                                    :jsonc
                                                                                    :latex
                                                                                    :lua
                                                                                    :make
                                                                                    :markdown
                                                                                    :markdown_inline
                                                                                    :ocaml
                                                                                    :proto
                                                                                    :python
                                                                                    :regex
                                                                                    :ruby
                                                                                    :rust
                                                                                    :scss
                                                                                    :solidity
                                                                                    :sql
                                                                                    :svelte
                                                                                    :swift
                                                                                    :todotxt
                                                                                    :toml
                                                                                    :tsx
                                                                                    :typescript
                                                                                    :vim
                                                                                    :vimdoc
                                                                                    :vue
                                                                                    :yaml
                                                                                    :zig]
                                                                 :highlight {:enable true
                                                                             :additional_vim_regex_highlighting true}}))})
