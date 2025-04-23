(import-macros {: pack : key} :Juliet.macros)

(pack :folke/trouble.nvim
      {:lazy false
       :config true
       :keys [(key :<leader>ld ":Trouble diagnostics<cr>"
                   "Document diagnostics")]})
