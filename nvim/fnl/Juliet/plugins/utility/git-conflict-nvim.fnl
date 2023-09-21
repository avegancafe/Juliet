(import-macros {: pack : key} :Juliet.macros)

(pack :akinsho/git-conflict.nvim
      {:config true
       :version "*"
       :lazy false
       :keys [(key :<leader>gl (fn [] (vim.cmd :GitConflictListQf)))]})
