(import-macros {: pack : key} :Juliet.macros)

(pack :echasnovski/mini.pick
      {:version false
       :lazy false
       :keys [(key :<c-p> ":Pick files<cr>"
                   "Fuzzy find a file")
              (key :<c-b> ":Pick buffers<cr>")
              "Fuzzy list buffers"]
       :dependencies [:natecraddock/workspaces.nvim]
       :config (fn []
                 (let [MiniPick (require :mini.pick)]
                   (MiniPick.setup {:mappings {:choose :<c-b>
                                               :choose_in_tabpage :<cr>
                                               :choose_marked :<c-cr>
                                               :paste :<c-r>}})))})
