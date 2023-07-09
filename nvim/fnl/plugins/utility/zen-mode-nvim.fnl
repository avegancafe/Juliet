(import-macros {: pack : key} :macros)

(pack :folke/zen-mode.nvim
      {:keys [(key :<c-f>
                   (fn []
                     (let [zen (require :zen-mode)] (zen.toggle))
                     (set vim.o.foldcolumn :1)
                     (set vim.o.foldlevel 99)
                     (set vim.o.foldenable true)
                     (set vim.o.number true)
                     (set vim.o.fillchars
                          "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"))
                   "Enter zen mode")]
       :config true
       :opts {:window {:backdrop 1
                       :height 0.73
                       :options {:number false :relativenumber false}}}})
