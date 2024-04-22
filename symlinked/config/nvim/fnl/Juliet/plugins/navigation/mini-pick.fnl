(import-macros {: pack : key} :Juliet.macros)

(fn cli-postprocess [items]
  (while (= (. items (length items)) "")
    (tset items (length items) nil))
  items)

(fn show-with-icon [buf-id items query]
  (let [MiniPick (require :mini.pick)]
    (MiniPick.default_show buf-id items query {:show_icons true})))

(fn postprocess [lines]
  (let [res (cli-postprocess lines)]
    (for [i 1 (length res)]
      (when (not= (: (. res i) :find ":") nil)
        (tset res i {:path (. res i) :text (. res i)})))
    res))

(local open-picker
       (fn []
         (let [pick (require :mini.pick)]
           (pick.builtin.cli {:command [:fd
                                        :--hidden
                                        :--type=f
                                        :--no-follow
                                        :--color=never]
                              : postprocess}
                             {:source {:name (string.format "Files (fd)")
                                       :show show-with-icon}}))))

(pack :echasnovski/mini.pick
      {:version false
       :lazy false
       :keys [(key :<c-p> open-picker "Fuzzy find a file")
              (key :<leader>p open-picker "Fuzzy find a file")
              (key :<c-b> ":Pick buffers<cr>")
              "Fuzzy list buffers"]
       :opts {:mappings {:choose :<c-o>
                         :choose_in_tabpage :<cr>
                         :choose_marked :<c-cr>
                         :paste :<c-r>}
              :options {:content_from_bottom true}}})
