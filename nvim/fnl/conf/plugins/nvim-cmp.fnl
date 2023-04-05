(import-macros {: pack} :themis.pack.lazy)

(pack :hrsh7th/nvim-cmp
      {:dependencies [:hrsh7th/cmp-nvim-lsp
                      :neovim/nvim-lspconfig
                      :hrsh7th/cmp-buffer
                      :onsails/lspkind.nvim
                      :L3MON4D3/LuaSnip]
       :config (fn []
                 (let [cmp (require :cmp)
                       lspkind (require :lspkind)]
                   (cmp.setup {:sorting {:comparators [cmp.config.compare.locality
                                                       cmp.config.compare.exact
                                                       cmp.config.compare.offset
                                                       cmp.config.compare.score
                                                       cmp.config.compare.sort_text]}
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
                               :sources (cmp.config.sources [{:name :nvim_lsp}
                                                             {:name :buffer}])})))})
