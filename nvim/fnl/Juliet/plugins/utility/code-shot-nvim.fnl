(import-macros {: pack} :Juliet.macros)

(pack :avegancafe/code-shot.nvim
      {:dependencies [:Aloxaf/silicon :avegancafe/core.nvim]
       :config (fn [] (local codeshot (require :code-shot))
                 (vim.keymap.set :v :<leader>bs
                                 "<cmd>lua require('code-shot').shot()<cr>"
                                 {:desc "Take a screenshot of code"})
                 (codeshot.setup))})
