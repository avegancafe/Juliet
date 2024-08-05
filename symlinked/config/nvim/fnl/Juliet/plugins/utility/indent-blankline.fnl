(import-macros {: pack} :Juliet.macros)

(pack :lukas-reineke/indent-blankline.nvim
      {:main :ibl
       :dependencies [:ribru17/bamboo.nvim]
       :opts {:indent {:highlight [:CustomIndentGuide]}
              :scope {:enabled false}}
       :config (fn [_ opts]
                 (let [ibl (require :ibl)
                       colors (require :bamboo.colors)
                       hooks (require :ibl.hooks)]
                   (hooks.register hooks.type.HIGHLIGHT_SETUP
                                   (fn []
                                     (vim.api.nvim_set_hl 0 :CustomIndentGuide
                                                          {:fg colors.bg1})))
                   (ibl.setup opts)))})
