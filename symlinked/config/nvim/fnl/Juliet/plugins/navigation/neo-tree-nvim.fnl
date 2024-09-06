(import-macros {: pack : key} :Juliet.macros)

(pack :nvim-neo-tree/neo-tree.nvim
      {:keys [(key :<leader>f ":Neotree<cr>" "Open file explorer")
              (key :<leader>ff ":Neotree reveal<cr>"
                   "focus current file in file explorer")]
       :event :VeryLazy
       :dependencies [:nvim-lua/plenary.nvim
                      :nvim-tree/nvim-web-devicons
                      :MunifTanjim/nui.nvim]
       :opts {:filesystem {:filtered_items {:hide_dotfiles false}}
              :window {:mappings {:<cr> :open_tabnew}}
              :default_component_configs {:git_status {:symbols {:unstaged :M
                                                                 :staged :U}}}}})
