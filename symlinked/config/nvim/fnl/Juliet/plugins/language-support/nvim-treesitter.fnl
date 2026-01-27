(import-macros {: pack} :Juliet.macros)

(pack :nvim-treesitter/nvim-treesitter
      {:build ":TSUpdate"
       :lazy false
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
                 (local ts (require :nvim-treesitter))
                 (ts.setup {:install_dir (.. (vim.fn.stdpath :data)
                                             :/lazy/nvim-treesitter/parser)
                            :highlight {:enable true
                                        :additional_vim_regex_highlighting true}})
                 (ts.install [:bash
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
                              :latex
                              :lua
                              :make
                              :markdown
                              :markdown_inline
                              :proto
                              :python
                              :regex
                              :ruby
                              :rust
                              :scss
                              :sql
                              :svelte
                              :swift
                              :todotxt
                              :toml
                              :typescript
                              :tsx
                              :vim
                              :vimdoc
                              :vue
                              :yaml
                              :zig]))})
