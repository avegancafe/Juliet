(import-macros {: pack : key} :Juliet.macros)

(pack :folke/snacks.nvim
      {:dependencies [:ribru17/bamboo.nvim]
       :opts {:indent {:enabled true}}
       :init (fn [] (local colors (require :bamboo.colors))
               (vim.api.nvim_set_hl 0 :SnacksIndent {:fg colors.bg1})
               (vim.api.nvim_set_hl 0 :SnacksIndentScope {:fg colors.grey}))})
