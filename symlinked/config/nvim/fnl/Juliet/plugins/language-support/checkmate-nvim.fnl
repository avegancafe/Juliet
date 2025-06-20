(import-macros {: pack : key} :Juliet.macros)

(pack :bngarren/checkmate.nvim
      {:opts {:keys {:<c-t> :toggle
                     :<c-n> :create
                     :<c-x> :check
                     :<c-u> :uncheck
                     :<c-a> :archive}
              :metadata {:priority {:key :<c-y>}
                         :started {:key :<c-s>}
                         :done {:key :<c-d>}}}
       :ft :markdown
       :keys [(key "<leader>\\"
                   ":execute 'bo vs ' . stdpath('data') . '/todo.md' | vertical resize 80<cr>")]})
