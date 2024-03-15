(import-macros {: pack : key} :Juliet.macros)

(pack :NeogitOrg/neogit
      {:opts {:disable_commit_confirmation true
              :kind :tab
              :auto_show_console false
              :graph_style :unicode}
       :dependencies [:nvim-lua/plenary.nvim
                      :nvim-telescope/telescope.nvim
                      :rcarriga/nvim-notify]
       :lazy false
       :keys [(key :<leader>g
                   (fn []
                     (let [neogit (require :neogit)] (neogit.open))))]})
