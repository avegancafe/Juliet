(import-macros {: pack : key} :Juliet.macros)

(pack :folke/trouble.nvim
      {:branch :dev
       :lazy false
       :config true
       :keys [(key :<leader>ld ":Trouble diagnostics<cr>"
                   "Document diagnostics")
              (key :<leader>l ":Trouble<cr>" "Open trouble")]})
