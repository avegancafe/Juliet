(import-macros {: pack : key} :Juliet.macros)

(pack :sbdchd/neoformat {:keys [(key :<leader>bf ":Neoformat<cr>"
                                     "Format buffer")]
                         :lazy false
                         :init (fn []
                                 (set vim.g.neoformat_enabled_sql [:sqlfluff])
                                 (set vim.g.neoformat_sql_sqlfluff
                                      {:exe :sqlfluff
                                       :args [:fix :--dialect :bigquery]
                                       :stdin 0
                                       :replace 1})
                                 (set vim.g.neoformat_python_ruff
                                      {:exe :ruff
                                       :args [:format "--line-length 120" "-"]
                                       :stdin 1}))})
