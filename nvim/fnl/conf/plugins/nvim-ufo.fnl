(import-macros {: pack} :themis.pack.lazy)

(pack :luukvbaal/statuscol.nvim
      {:config true :opts {:foldfunc :builtin :setopt true}})

(pack :kevinhwang91/nvim-ufo
      {:dependencies [:kevinhwang91/promise-async :luukvbaal/statuscol.nvim]
       :config (fn []
                   (set vim.o.foldcolumn :0)
                   (set vim.o.foldlevel 99)
                   (set vim.o.foldenable true)
                   (set vim.o.fillchars
                        "eob: ,fold: ,foldopen:,foldsep: ,foldclose:")
                 (let [ufo (require :ufo)]
                   (ufo.setup {:provider_selector (fn []
                                                    [:treesitter :indent])})))})
