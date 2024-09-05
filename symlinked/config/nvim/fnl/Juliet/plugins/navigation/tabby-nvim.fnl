(import-macros {: pack : key} :Juliet.macros)
(local {: current-cal-event} (require :Juliet.utils))

(local highlight-groups {:current_tab :TabLineSel
                         :fill :TabLineFill
                         :head :TabLine
                         :tab :TabLine
                         :win :TabLine
                         :sep :TabLineSep})

(lambda num-of-bufs [tab line]
  (length (. (line.wins_in_tab tab) :wins)))

(lambda render-tab [tab line]
  (local buffer
         (vim.api.nvim_buf_get_name (. ((. (tab.current_win) :buf)) :id)))
  (local parse-path
         (fn [full-path]
           (if (= full-path "") "[No Name]"
               (string.match full-path "([%a%d-_%.:%s]*)$"))))
  (local parse-index (fn [full-path]
                       (string.gsub (string.match full-path
                                                  "([%a-_.]+/[%a.]+)$")
                                    :index. :i.)))
  (local buffer-name (if (string.match buffer "index.[tj]sx?$")
                         (parse-index buffer)
                         (parse-path buffer)))
  (let [hl (or (and (tab.is_current) highlight-groups.current_tab)
               highlight-groups.tab)]
    {1 (line.sep " " (or (and (tab.is_current) highlight-groups.sep)
                         highlight-groups.fill)
                 highlight-groups.head)
     2 (line.sep (if (accumulate [found false _ win (ipairs (. (tab.wins) :wins))]
                       (or found ((. (win.buf) :is_changed))))
                     "• "
                     "") highlight-groups.tab
                 highlight-groups.tab)
     3 (let [width vim.opt.columns._value
             buf-info (vim.fn.getbufinfo {:buflisted 1})
             buf-num (length buf-info)
             ideal-max-width 30
             equal-sized-width (vim.fn.float2nr (vim.fn.floor (/ width buf-num)))
             actual-max-width (vim.fn.min [equal-sized-width ideal-max-width])
             full-text (if (> (num-of-bufs tab.id line) 1)
                           (.. buffer-name " (+)")
                           buffer-name)
             suffix (if (> (length full-text) actual-max-width) "…" "")
             len-text (if (> (length full-text) actual-max-width)
                          (- actual-max-width 1)
                          (length full-text))
             actual-text (.. (full-text:sub 0 len-text) suffix)]
         actual-text)
     4 (line.sep " " highlight-groups.tab highlight-groups.tab)
     5 (tab.close_btn " ")
     : hl
     :margin ""}))

(lambda render-buffers [win line i]
  (local fin (or (and (> (length (. (line.wins_in_tab (line.api.get_current_tab))
                                    :wins)) 1)
                      {1 (line.sep "" highlight-groups.win
                                   highlight-groups.fill)
                       2 (or (and (win.is_current) "") "")
                       3 (win.buf_name)
                       4 (or (and ((. (win.buf) :is_changed))
                                  (line.sep "[+]" highlight-groups.tab
                                            highlight-groups.tab))
                             "")
                       5 (or (and (< i.value
                                     (- (num-of-bufs (line.api.get_current_tab)
                                                     line)
                                        1))
                                  (line.sep "|" highlight-groups.fill
                                            highlight-groups.tab))
                             "")
                       :hl (or (and (win.is_current)
                                    highlight-groups.current_tab)
                               highlight-groups.win)
                       :margin " "}) ""))
  (set i.value (+ i.value 1))
  fin)

(pack :nanozuki/tabby.nvim
      {:init (fn [] (tset vim.o :showtabline 2))
       :dependencies [:ribru17/bamboo.nvim]
       :lazy false
       :keys [(key :<tab> :gt "Next tab")
              (key :<s-tab> :gT "Previous tab")
              (key :<leader><tab> ":+tabmove<cr>" "Move tab to the right")
              (key :<leader><s-tab> ":-tabmove<cr>" "Move tab to the left")]
       :config (fn []
                 (local tabline (require :tabby.tabline))
                 (tabline.set (fn [line]
                                ; I don't know how to make this mutable to children so boxed var it is
                                (var i {:value 0})
                                {1 ((. (line.tabs) :foreach) (fn [tab]
                                                               (render-tab tab
                                                                           line)))
                                 2 (line.spacer)
                                 3 (if (> (length (current-cal-event)) 0)
                                       (.. (current-cal-event) " ")
                                       ((. (line.wins_in_tab (line.api.get_current_tab))
                                           :foreach) (fn [win]
                                                                                                                                                (render-buffers win
                                                                                                                                                                line
                                                                                                                                                                i))))
                                 :hl highlight-groups.fill})))})
