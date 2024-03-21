(import-macros {: pack : key} :Juliet.macros)

(pack :sbdchd/neoformat
      {:keys [(key :<leader>bf ":Neoformat<cr>" "Format buffer")]
       :lazy false
       :init (fn []
               (set vim.g.neoformat_python_ruff
                    {:exe :ruff :args [:format "--line-length 120" "-"] :stdin 1}))})
