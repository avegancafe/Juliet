(import-macros {: pack : key} :Juliet.macros)

(pack :folke/todo-comments.nvim {:dependencies [:nvim-lua/plenary.nvim]
                                 :config true
                                 :keys [(key :<leader>bt :<cmd>TodoTrouble<cr>
                                             "List Todos in pwd")]
                                 :opts {}})
