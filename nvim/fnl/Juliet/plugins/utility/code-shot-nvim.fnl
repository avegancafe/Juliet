(import-macros {: pack} :Juliet.macros)

(pack :avegancafe/code-shot.nvim
      {:dependencies [:Aloxaf/silicon :avegancafe/core.nvim]
       :init (fn []
               (vim.keymap.set :v :<leader>bs
                               "<cmd>lua require('code-shot').shot()<cr>"
                               {:desc "Take a screenshot of code"}))
       :config (fn []
                 (local codeshot (require :code-shot))
                 (codeshot.setup {:options (fn [select-area]
                                             (print "getting custom opts")
                                             [:-f
                                              "Iosevka Term"
                                              :--line-offset
                                              select-area.s_start.row])}))})
