(import-macros {: pack : key} :Juliet.macros)

(pack :bngarren/checkmate.nvim
      {:opts {:keys {:<c-t> {:rhs "<cmd>Checkmate toggle<cr>"}
                     :<c-n> {:rhs "<cmd>Checkmate create<cr>"}
                     :<c-x> {:rhs "<cmd>Checkmate check<cr>"}
                     :<c-u> {:rhs "<cmd>Checkmate uncheck<cr>"}
                     :<c-a> {:rhs "<cmd>Checkmate archive<cr>"}}
              :metadata {:priority {:key :<c-y>}
                         :started {:key :<c-s>}
                         :done {:key :<c-d>}}}
       :ft :markdown
       :keys [(key "<leader>\\"
                   ":execute 'bo vs ' . stdpath('data') . '/todo.md' | vertical resize 80<cr>")]})
