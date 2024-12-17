(import-macros {: pack : key} :Juliet.macros)

(pack :atiladefreitas/dooing
      {:opts {}
       :lazy false
       :keys [(key :<leader>q ":Dooing<cr>" "Open todo list")]})
