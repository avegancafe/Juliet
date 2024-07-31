(import-macros {: pack : key} :Juliet.macros)

(pack :folke/zen-mode.nvim
      {:dependencies [:folke/twilight.nvim]
       :keys [(key :<c-f>
                   (fn []
                     (let [zen (require :zen-mode)] (zen.toggle))
                     (set vim.o.number true)
                     (set vim.o.signcolumn :yes))
                   "Enter zen mode")]
       :config true
       :opts {:window {:backdrop 1
                       :height 1
                       :width 0.85
                       :options {:number false :relativenumber false}}}})
