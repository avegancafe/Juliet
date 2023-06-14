(import-macros {: pack} :macros)

[(pack :j-hui/fidget.nvim
       {:config true
        :tag :legacy
        :opts {:text {:spinner :dots :done "✓"} :timer {:spinner_rate 50}}})
 (pack :smjonas/inc-rename.nvim {:config true})
 (pack :tomlion/vim-solidity {:ft :solidity})
 (pack :glepnir/lspsaga.nvim {:event :LspAttach
                              :dependencies [:kyazdani42/nvim-web-devicons
                                             :nvim-treesitter/nvim-treesitter]
                              :init (fn []
                                      (vim.fn.sign_define :DiagnosticSignError
                                                          {:texthl :DiagnosticSignError
                                                           :text ""
                                                           :numhl :DiagnosticSignError})
                                      (vim.fn.sign_define :DiagnosticSignWarn
                                                          {:texthl :DiagnosticSignWarn
                                                           :text ""
                                                           :numhl :DiagnosticSignWarn})
                                      (vim.fn.sign_define :DiagnosticSignHint
                                                          {:texthl :DiagnosticSignHint
                                                           :text ""
                                                           :numhl :DiagnosticSignHint})
                                      (vim.fn.sign_define :DiagnosticSignInfo
                                                          {:texthl :DiagnosticSignInfo
                                                           :text ""
                                                           :numhl :DiagnosticSignInfo}))
                              :opts {:outline {:win_width 40
                                               :keys {:jump :<cr>
                                                      :expand_collapse :u}}
                                     :ui {:border :rounded}
                                     :symbol_in_winbar {:enable false
                                                        :separator "  "
                                                        :hide_keyword false
                                                        :show_file true
                                                        :respect_root true
                                                        :color_mode true}}
                              :config true})
 [(pack :williamboman/mason.nvim
        {:config (fn []
                   (local mason (require :mason))
                   (mason.setup {:ui {:border :rounded :width 0.6 :height 0.7}})
                   (vim.cmd "autocmd FileType mason setlocal winblend=10")
                   (vim.api.nvim_create_autocmd [:BufEnter :BufWinEnter]
                                                {:pattern :*.yml
                                                 :callback (fn []
                                                             (vim.diagnostic.hide))}))})
  :williamboman/mason-lspconfig.nvim
  :neovim/nvim-lspconfig
  :onsails/lspkind.nvim
  (pack :ray-x/lsp_signature.nvim {:config true})]
 (pack :SmiteshP/nvim-navic {:dependencies [:neovim/nvim-lspconfig]})
 (pack :hrsh7th/nvim-cmp
       {:dependencies [:hrsh7th/cmp-nvim-lsp
                       :neovim/nvim-lspconfig
                       :hrsh7th/cmp-buffer
                       :onsails/lspkind.nvim
                       :L3MON4D3/LuaSnip]
        :config (fn []
                  (let [cmp (require :cmp)
                        lspkind (require :lspkind)]
                    (cmp.setup {:completion {:autocomplete [cmp.TriggerEvent.InsertEnter
                                                            cmp.TriggerEvent.TextChanged]}
                                :sorting {:comparators [cmp.config.compare.exact cmp.config.compare.length]}
                                :formatting {:format (lspkind.cmp_format {:mode :symbol_text
                                                                          :maxwidth 50
                                                                          :ellipsis_char "..."})}
                                :snippet {:expand (fn [args]
                                                    (let [snip (require :luasnip)]
                                                      (snip.lsp_expand args.body)))}
                                :window {:completion (cmp.config.window.bordered)
                                         :documentation (cmp.config.window.bordered)}
                                :mapping (cmp.mapping.preset.insert {:<c-e> (cmp.mapping.abort)
                                                                     :<Tab> (cmp.mapping.confirm {:select true})})
                                :sources (cmp.config.sources [{:name :buffer}
                                                              {:name :nvim_lsp}])})))})
 (pack :mfussenegger/nvim-lint
       {:config (fn []
                  (let [lint (require :lint)
                        golangcilint (require :lint.linters.golangcilint)]
                    (tset lint :linters_by_ft
                          {:go [:golangcilint]
                           :javascript [:eslint]
                           :typescript [:eslint]
                           :typescriptreact [:eslint]})
                    (tset golangcilint :append_fname true)
                    (tset golangcilint :args
                          [:run
                           :--out-format
                           :json
                           :--config
                           "~/workspace/api-v2-backend/.build/scripts/.golangci.yml"])
                    (vim.api.nvim_create_autocmd [:BufWrite :BufRead]
                                                 {:callback (fn []
                                                              (let [lint (require :lint)]
                                                                (lint.try_lint nil
                                                                               {:ignore_errors true})))})
                    nil))})
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
                                                                                     :jsdoc
                                                                                     :json
                                                                                     :json5
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
                                                                                     :vue]
                                                                  :highlight {:enable true
                                                                              :additional_vim_regex_highlighting true}}))})
 (pack :RRethy/vim-illuminate
       {:config (fn []
                  (let [illuminate (require :illuminate)]
                    (illuminate.configure {:filetypes_denylist [:dashboard
                                                                :lspsagaoutline
                                                                :NvimTree]})))})
 (pack :tomlion/vim-solidity {:ft :solidity})
 :folke/trouble.nvim
 :frazrepo/vim-rainbow
 :tpope/vim-surround
 :othree/yajs.vim
 :tpope/vim-sleuth]
