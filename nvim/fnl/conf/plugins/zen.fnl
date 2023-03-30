(import-macros {: pack} :themis.pack.lazy)

(pack :folke/zen-mode.nvim
      {:config true
       :opts {:window {:backdrop 1
                       :height 0.73
                       :options {:number false :relativenumber false}}}})
