(import-macros {: pack} :themis.pack.lazy)

(pack :akinsho/bufferline.nvim
      {:config (fn []
                 ((. (require :cmds.setup_bufferline) :setup) :buffers))})
