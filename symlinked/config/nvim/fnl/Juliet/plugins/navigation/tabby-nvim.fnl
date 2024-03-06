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
                 (local theme {:current_tab :TabLineSel
                               :fill :TabLineFill
                               :head :TabLine
                               :tab :TabLine
                               :win :TabLine
                               :sep :TabLineSep})
                 (tabline.set (fn [line]
                                (var i 0)
                                {1 ((. (line.tabs) :foreach) (fn [tab]
                                                               (local buffer
                                                                      (vim.api.nvim_buf_get_name (. ((. (tab.current_win)
                                                                                                        :buf))
                                                                                                    :id)))
                                                               (local parse-path
                                                                      (fn [full-path]
                                                                        (if (= full-path
                                                                               "")
                                                                            "[No Name]"
                                                                            (string.match full-path
                                                                                          "([%a%d-_%.]*)$"))))
                                                               (local parse-index
                                                                      (fn [full-path]
                                                                        (string.gsub (string.match full-path
                                                                                                   "([%a-_.]+/[%a.]+)$")
                                                                                     :index.
                                                                                     :i.)))
                                                               (local buffer-name
                                                                      (if (string.match buffer
                                                                                        "index.[tj]sx?$")
                                                                          (parse-index buffer)
                                                                          (parse-path buffer)))
                                                               (let [hl (or (and (tab.is_current)
                                                                                 theme.current_tab)
                                                                            theme.tab)]
                                                                 {1 (line.sep "▎"
                                                                              (or (and (tab.is_current)
                                                                                       theme.sep)
                                                                                  theme.fill)
                                                                              theme.head)
                                                                  2 (line.sep (if (accumulate [found false _ win (ipairs (. (tab.wins)
                                                                                                                             :wins))]
                                                                                     (or found
                                                                                         ((. (win.buf)
                                                                                             :is_changed))))
                                                                                   "• " "")
                                                                              theme.tab
                                                                              theme.tab)
                                                                  3 buffer-name
                                                                  4 (line.sep " "
                                                                              theme.tab
                                                                              theme.tab)
                                                                  5 (tab.close_btn " ")
                                                                  : hl
                                                                  :margin ""})))
                                 2 (line.spacer)
                                 3 ((. (line.wins_in_tab (line.api.get_current_tab))
                                       :foreach) (fn [win]
                                                                                                                                        (local num-of-bufs
                                                                                                                                               (length (. (line.wins_in_tab (line.api.get_current_tab))
                                                                                                                                                          :wins)))
                                                                                                                                        (local fin
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
                                                                                                                                                         4 (or (and ((. (win.buf)
                                                                                                                                                                        :is_changed))
                                                                                                                                                                    (line.sep "[+]"
                                                                                                                                                                              theme.tab
                                                                                                                                                                              theme.tab))
                                                                                                                                                               "")
                                                                                                                                                         5 (or (and (< i
                                                                                                                                                                       (- num-of-bufs
                                                                                                                                                                          1))
                                                                                                                                                                    (line.sep "|"
                                                                                                                                                                              theme.fill
                                                                                                                                                                              theme.tab))
                                                                                                                                                               "")
                                                                                                                                                         :hl (or (and (win.is_current)
                                                                                                                                                                      theme.current_tab)
                                                                                                                                                                 theme.win)
                                                                                                                                                         :margin " "})
                                                                                                                                                   ""))
                                                                                                                                        (set i
                                                                                                                                             (+ i
                                                                                                                                                1))
                                                                                                                                        fin))
                                 :hl theme.fill})))})
