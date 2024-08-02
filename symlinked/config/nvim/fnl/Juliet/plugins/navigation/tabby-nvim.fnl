(import-macros {: pack : key} :Juliet.macros)

(local event-cache {:refresh_interval 30 :timestamp nil :value nil})

(fn current-cal-event []
  (let [now (os.time)]
    (when (and event-cache.value
               (< (- now event-cache.timestamp) event-cache.refresh_interval))
      (let [___antifnl_rtn_1___ event-cache.value]
        (lua "return ___antifnl_rtn_1___")))
    (local script "set processExists to false
        tell application \"System Events\"
            set processList to name of every process
            if processList contains \"Notion Calendar\" then
                set processExists to true
            end if
        end tell
        if processExists then
          tell application \"System Events\"
            tell process \"Notion Calendar\"
              -- Get the second menu bar
              set theSecondMenuBar to menu bar 2
              -- Get all menu bar items in the second menu bar
              set menuBarItems to menu bar items of theSecondMenuBar
              -- Collect the titles or values of each menu bar item
              set menuBarItemTitles to {}
              repeat with itemIndex from 1 to count of menuBarItems
                set menuBarItemTitle to value of attribute \"AXTitle\" of item itemIndex of menuBarItems
                set end of menuBarItemTitles to menuBarItemTitle
              end repeat
            end tell
          end tell
          return menuBarItemTitles as string
        else
          return \"Open Notion Calendar to see upcoming events\"
        end if")
    (local handle (io.popen (.. "osascript -e '" script "'")))
    (when (= handle nil)
      (set event-cache.value "Nothing's up")
      (set event-cache.timestamp now)
      (let [__fnl_ret_val event-cache.value]
        (lua "return __fnl_ret_val")))
    (local result (handle:read :*a))
    (handle:close)
    (set event-cache.value (result:gsub "^%s*(.-)%s*$" "%1"))
    (set event-cache.timestamp now)
    result))

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

                                (fn num-of-bufs [tab]
                                  (length (. (line.wins_in_tab tab) :wins)))

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
                                                                                          "([%a%d-_%.:]*)$"))))
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
                                                                                  "• "
                                                                                  "")
                                                                              theme.tab
                                                                              theme.tab)
                                                                  3 (if (> (num-of-bufs tab.id)
                                                                           1)
                                                                        (.. buffer-name
                                                                            " (+)")
                                                                        buffer-name)
                                                                  4 (line.sep " "
                                                                              theme.tab
                                                                              theme.tab)
                                                                  5 (tab.close_btn " ")
                                                                  : hl
                                                                  :margin ""})))
                                 2 (line.spacer)
                                 3 (if (> (length (current-cal-event)) 0)
                                       (.. (current-cal-event) " ")
                                       ((. (line.wins_in_tab (line.api.get_current_tab))
                                           :foreach) (fn [win]
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
                                                                                                                                                                               (- (num-of-bufs (line.api.get_current_tab))
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
                                                                                                                                                fin)))
                                 :hl theme.fill})))})
