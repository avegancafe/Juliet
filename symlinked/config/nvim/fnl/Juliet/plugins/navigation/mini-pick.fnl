(import-macros {: pack : key} :Juliet.macros)

(pack :echasnovski/mini.pick
      {:version false
       :lazy false
       :keys [(key :<c-p>
                   (fn []
                     (let [pick (require :mini.pick)]
                       (pick.builtin.files {:tool :fd})))
                   "Fuzzy find a file")
              (key :<leader>p
                   (fn []
                     (let [pick (require :mini.pick)]
                       (pick.builtin.files {:tool :fd})))
                   "Fuzzy find a file")
              (key :<c-b> ":Pick buffers<cr>")
              "Fuzzy list buffers"]
       :opts {:mappings {:choose :<c-o>
                         :choose_in_tabpage :<cr>
                         :choose_marked :<c-cr>
                         :paste :<c-r>}
              :options {:content_from_bottom true}}})
