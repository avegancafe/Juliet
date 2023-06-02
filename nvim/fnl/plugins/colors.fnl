(import-macros {: pack} :macros)

(pack :ribru17/bamboo.nvim
      {:config (fn []
                 (let [bamboo (require :bamboo)]
                   (bamboo.setup {})
                   (bamboo.load)))})
