(import-macros {: pack} :macros)

(pack :akinsho/bufferline.nvim
      {:config (fn []
                 ((. (require :cmds.setup_bufferline) :setup) :buffers))})

