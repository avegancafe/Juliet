(import-macros {: pack : key} :Juliet.macros)

(pack :folke/zen-mode.nvim
      {:keys [(key :<c-f>
                   (fn []
                     (let [zen (require :zen-mode)] (zen.toggle))
                     (set vim.o.foldcolumn :1)
                     (set vim.o.foldlevel 99)
                     (set vim.o.foldenable true)
                     (set vim.o.number true)
                     (set vim.o.fillchars
                          "eob: ,fold: ,foldopen:v,foldsep: ,foldclose:>")
                     (set vim.o.signcolumn :yes))
                   "Enter zen mode")]
       :config true
       :opts {:window {:backdrop 1
                       :height 0.9
                       :width 0.85
                       :options {:number false :relativenumber false}}}})
