(import-macros {: pack : key} :Juliet.macros)

(pack :mikavilpas/yazi.nvim
      {:event :VeryLazy
       :opts {}
       :keys [(key :<leader>fx "<cmd>Yazi cwd<cr>" "File explorer to the max")
              (key :<leader>fxx :<cmd>Yazi<cr> "File explorer at current file")]})
