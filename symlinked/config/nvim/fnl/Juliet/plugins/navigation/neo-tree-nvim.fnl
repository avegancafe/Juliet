(import-macros {: pack : key} :Juliet.macros)

(pack :nvim-neo-tree/neo-tree.nvim
      {:keys [(key :<leader>f ":Neotree<cr>" "Open file explorer")
              (key :<leader>ff ":Neotree reveal<cr>"
                   "focus current file in file explorer")]
       :event :VeryLazy
       :dependencies [:nvim-lua/plenary.nvim
                      :nvim-tree/nvim-web-devicons
                      :MunifTanjim/nui.nvim]
       :opts {:window {:mappings {:<cr> :open_tabnew}}}})
