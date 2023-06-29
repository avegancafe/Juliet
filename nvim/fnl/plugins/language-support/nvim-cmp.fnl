(import-macros {: pack} :macros)

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
                               :sorting {:comparators [cmp.config.compare.offset
                                                       cmp.config.compare.exact
                                                       cmp.config.compare.score
                                                       (fn [entry1 entry2]
                                                         (var (_ entry1-under)
                                                              (entry1.completion_item.label:find "^_+"))
                                                         (var (_ entry2-under)
                                                              (entry2.completion_item.label:find "^_+"))
                                                         (set entry1-under
                                                              (or entry1-under
                                                                  0))
                                                         (set entry2-under
                                                              (or entry2-under
                                                                  0))
                                                         (if (> entry1-under
                                                                entry2-under)
                                                             false
                                                             (< entry1-under
                                                                entry2-under)
                                                             true))
                                                       cmp.config.compare.kind
                                                       cmp.config.compare.sort_text
                                                       cmp.config.compare.length
                                                       cmp.config.compare.order]}
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
