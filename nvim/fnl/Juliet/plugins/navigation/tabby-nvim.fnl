(import-macros {: pack : key} :Juliet.macros)

(pack :nanozuki/tabby.nvim
      {:init (fn [] (tset vim.o :showtabline 2))
       :dependencies [:ribru17/bamboo.nvim]
       :lazy false
       :keys [(key :<tab> :gt "Next tab")
              (key :<s-tab> :gT "Previous tab")
              (key :<leader><tab> ":+tabmove<cr>" "Move tab to the right")
              (key :<leader><s-tab> ":-tabmove<cr>" "Move tab to the left")
              (key :<leader><tab>o ":tabonly<cr>" "Isolate tab")]
       :config (fn []
                 (local tabline (require :tabby.tabline))
                 (local colors (require :bamboo.colors))
                 (local theme
                        {:current_tab :TabLineSel
                         :fill :TabLineFill
                         :head :TabLine
                         :tab :TabLine
                         :tail :TabLine
                         :win :TabLine
                         :sep :TabLineSep
                         :logo :TabLineLogo})
                 (vim.api.nvim_set_hl 0 theme.logo
                                      {:fg colors.red :bg colors.black})
                 (vim.api.nvim_set_hl 0 theme.sep {:bg colors.green})
                 (vim.api.nvim_set_hl 0 theme.head
                                      {:bg colors.white :fg colors.white})
                 (vim.api.nvim_set_hl 0 theme.current_tab {:bg colors.bg0})
                 (vim.api.nvim_set_hl 0 theme.tab {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 theme.fill
                                      {:fg colors.black :bg colors.black})
                 (tabline.set (fn [line]
                                {1 ((. (line.tabs) :foreach) (fn [tab]
                                                               (let [hl (or (and (tab.is_current)
                                                                                 theme.current_tab)
                                                                            theme.tab)]
                                                                 {1 (line.sep "▎"
                                                                              (or (and (tab.is_current)
                                                                                       theme.sep)
                                                                                  theme.fill)
                                                                              theme.head)
                                                                  2 (tab.name)
                                                                  3 (tab.close_btn "")
                                                                  4 (line.sep ""
                                                                              hl
                                                                              theme.fill)
                                                                  : hl
                                                                  :margin " "})))
                                 2 (line.spacer)
                                 3 ((. (line.wins_in_tab (line.api.get_current_tab))
                                       :foreach) (fn [win]
                                                                                                                                        (or (and (> (length (. (line.wins_in_tab (line.api.get_current_tab))
                                                                                                                                                               :wins))
                                                                                                                                                    1)
                                                                                                                                                 {1 (line.sep ""
                                                                                                                                                              theme.win
                                                                                                                                                              theme.fill)
                                                                                                                                                  2 (or (and (win.is_current)
                                                                                                                                                             "")
                                                                                                                                                        "")
                                                                                                                                                  3 (win.buf_name)
                                                                                                                                                  4 (line.sep "|"
                                                                                                                                                              theme.fill
                                                                                                                                                              theme.tab)
                                                                                                                                                  :hl (or (and (win.is_current)
                                                                                                                                                               theme.current_tab)
                                                                                                                                                          theme.win)
                                                                                                                                                  :margin " "})
                                                                                                                                            "")))
                                 :hl theme.fill})))})
