(import-macros {: pack} :macros)

(pack :akinsho/bufferline.nvim
      {:dependencies [:ribru17/bamboo.nvim]
       :config (fn []
                 ((. (require :cmds.setup_bufferline) :setup) :buffers))})
