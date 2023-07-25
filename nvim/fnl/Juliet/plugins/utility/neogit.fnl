(import-macros {: pack : key} :Juliet.macros)

(pack :NeogitOrg/neogit
      {:config true
       :opts {:disable_commit_confirmation true}
       :dependencies [:nvim-lua/plenary.nvim :nvim-telescope/telescope.nvim]
       :keys [(key :<leader>g
                   (fn []
                     (let [neogit (require :neogit)] (neogit.open))))]})