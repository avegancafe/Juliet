(import-macros {: pack : key} :Juliet.macros)

(pack :folke/trouble.nvim
      {:keys [(key :<leader>dd ":TroubleToggle document_diagnostics<cr>"
                   "Document diagnostics")
              (key :<leader>d ":TroubleToggle<cr>" "Open trouble")
              (key :<leader>d5 ":TroubleRefresh<cr>" "Refresh trouble")]})
