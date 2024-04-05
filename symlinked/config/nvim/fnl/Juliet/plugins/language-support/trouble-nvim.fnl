(import-macros {: pack : key} :Juliet.macros)

(pack :folke/trouble.nvim
      {:branch :dev
       :keys [(key :<leader>ld ":TroubleToggle document_diagnostics<cr>"
                   "Document diagnostics")
              (key :<leader>l ":TroubleToggle<cr>" "Open trouble")
              (key :<leader>l5 ":TroubleRefresh<cr>" "Refresh trouble")]})
