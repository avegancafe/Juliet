(import-macros {: pack : key} :Juliet.macros)

(pack :avegancafe/completionist.nvim
      {:lazy false
       :keys [(key "<leader>\\"
                   (fn [] (local completionist (require :completionist))
                     (completionist.toggle)) "Open notepad")]
       :dependencies [:nvim-lua/plenary.nvim :ribru17/bamboo.nvim]
       :config (fn []
                 (let [completionist (require :completionist)
                       colors (require :bamboo.colors)]
                   (completionist.setup {:colors {:normal colors.fg
                                                  :done colors.gray
                                                  :medium colors.yellow
                                                  :high colors.red}})))})
