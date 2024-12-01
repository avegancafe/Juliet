(import-macros {: pack} :Juliet.macros)
(local {: merge} (require :Juliet.utils))

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
                               :sorting {:comparators [cmp.config.compare.locality
                                                       cmp.config.compare.recently_used
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
                                                       cmp.config.compare.offset
                                                       cmp.config.compare.order]}
                               :snippet {:expand (fn [args]
                                                   (let [snip (require :luasnip)]
                                                     (snip.lsp_expand args.body)))}
                               :window {:completion (merge (cmp.config.window.bordered)
                                                           {:col_offset -3
                                                            :side_padding 1})
                                        :documentation (cmp.config.window.bordered)}
                               :formatting {:fields [:kind :abbr :menu]
                                            :format (fn [entry vim-item]
                                                      (local lspkind
                                                             (require :lspkind))
                                                      (local kind
                                                             ((lspkind.cmp_format {:mode :symbol_text
                                                                                   :maxwidth 30
                                                                                   :ellipsis_char "…"}) entry
                                                                                                                                                                                                                                                                                                               vim-item))
                                                      kind)}
                               :mapping (cmp.mapping.preset.insert {:<c-e> (cmp.mapping.abort)
                                                                    :<cr> (cmp.mapping.confirm {:select true})
                                                                    :<C-k> (cmp.mapping {:i (fn []
                                                                                              (if (cmp.visible)
                                                                                                  (cmp.abort)
                                                                                                  (cmp.complete)))})})
                               :sources (cmp.config.sources [{:name :nvim_lsp}])})))})
