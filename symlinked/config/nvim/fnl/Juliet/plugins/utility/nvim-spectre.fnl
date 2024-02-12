(import-macros {: pack : key} :Juliet.macros)

(pack :nvim-pack/nvim-spectre
      {:dependencies [:nvim-lua/plenary.nvim]
       :lazy false
       :keys [(key :<leader>fr
                   (fn [] (local spectre (require :spectre)) (spectre.toggle))
                   "Find & replace")]
       :opts {}})
