(import-macros {: pack : key} :Juliet.macros)

(pack :stevearc/oil.nvim {:keys [(key :<leader>f ":Oil --float<cr>"
                                      "Open file explorer")
                                 (key :<leader>ff ":Oil --float %:p:h<cr>" "Open file explorer in current directory")]
                          :opts {}})
