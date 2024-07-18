(import-macros {: pack : key} :Juliet.macros)

(pack :nvim-neo-tree/neo-tree.nvim
      {:keys [(key :<leader>f "<cmd>Neotree<cr>" "Open file explorer")
              (key :<leader>ff "<cmd>Neotree reveal<cr>"
                   "Open file explorer in current directory")]
       :dependencies [:nvim-lua/plenary.nvim
                      :nvim-tree/nvim-web-devicons
                      :MunifTanjim/nui.nvim]})
