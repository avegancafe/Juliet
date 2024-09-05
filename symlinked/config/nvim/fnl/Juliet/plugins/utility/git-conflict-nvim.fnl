(import-macros {: pack : key} :Juliet.macros)

(pack :akinsho/git-conflict.nvim
      {:config true
       :version "*"
       :lazy false
       :opts {:list_opener (fn []
                             (let [trouble (require :trouble)]
                               (trouble.toggle :quickfix)))}
       :keys [(key :<leader>gc (fn [] (vim.cmd :GitConflictListQf))
                   "Open all git merge conflicts in quickfix menu")
              (key :<leader>gcn
                   (fn []
                     (vim.cmd :GitConflictNextConflict
                              "Navigate to next git conflict in current buffer")))
              (key :<leader>gcp
                   (fn []
                     (vim.cmd :GitConflictPrevConflict
                              "Navigate to previous git conflict in current buffer")))
              ]})
