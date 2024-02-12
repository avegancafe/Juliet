(import-macros {: pack} :Juliet.macros)

(pack :niuiic/code-shot.nvim
      {:dependencies [:Aloxaf/silicon :niuiic/core.nvim]
       :init (fn []
               (vim.keymap.set :v :<leader>bs
                               "<cmd>lua require('code-shot').shot()<cr>"
                               {:desc "Take a screenshot of code"}))
       :config (fn []
                 (local codeshot (require :code-shot))
                 (codeshot.setup {:options (fn [select-area]
                                             [:-f
                                              "Iosevka Term"
                                              :--line-offset
                                              select-area.start_line])}))})
