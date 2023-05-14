(import-macros {: pack} :themis.pack.lazy)

(pack :luukvbaal/statuscol.nvim
      {:config true :opts {:foldfunc :builtin :setopt true}})

(pack :kevinhwang91/nvim-ufo
      {:dependencies [:kevinhwang91/promise-async :luukvbaal/statuscol.nvim]
       :init (fn []
               (set vim.o.foldcolumn :1)
               (set vim.o.foldlevel 99)
               (set vim.o.foldenable true)
               (set vim.o.fillchars
                    "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"))
       :config true
       :opts {:provider_selector (fn []
                                   [:treesitter :indent])}})
