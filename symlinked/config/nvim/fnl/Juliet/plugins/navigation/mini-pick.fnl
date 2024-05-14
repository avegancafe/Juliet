(import-macros {: pack : key} :Juliet.macros)

(pack :echasnovski/mini.pick
      {:version false
       :lazy false
       :keys [(key :<c-p> "<CMD>Pick files_fd<CR>" "Fuzzy find a file")
              (key :<leader>p "<CMD>Pick files_fd<CR>" "Fuzzy find a file")
              (key :<c-b> ":Pick buffers<cr>")
              "Fuzzy list buffers"]
       :init (fn []
               (let [MiniPick (require :mini.pick)
                     command [:fd
                              :--hidden
                              :--type=f
                              :--no-ignore
                              :--ignore-file
                              (vim.fn.expand "$HOME/.gitignore_global")
                              :--no-follow
                              :--color=never]
                     show-with-icons (fn [buf-id items query]
                                       (MiniPick.default_show buf-id items
                                         query
                                         {:show_icons true}))
                     source {:name "Files (fd)" :show show-with-icons}]
                 (set MiniPick.registry.files_fd
                      (fn [] (MiniPick.builtin.cli {: command} {: source})))))
       :opts {:mappings {:choose :<c-o>
                         :choose_in_tabpage :<cr>
                         :choose_marked :<c-cr>
                         :paste :<c-r>}
              :options {:content_from_bottom true}}})
