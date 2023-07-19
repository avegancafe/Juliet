(import-macros {: pack : key} :Juliet.macros)

(pack :kevinhwang91/nvim-ufo
      {:lazy false
       :keys [(key :zR
                   (fn []
                     (let [ufo (require :ufo)] (ufo.openAllFolds))))
              (key :zM
                   (fn []
                     (let [ufo (require :ufo)] (ufo.closeAllFolds))))]
       :dependencies [:kevinhwang91/promise-async
                      (pack :luukvbaal/statuscol.nvim
                            {:config (fn []
                                       (let [statuscol (require :statuscol)
                                             builtin (require :statuscol.builtin)]
                                         (statuscol.setup {:foldfunc :builtin
                                                           :setopt true
                                                           :relculright true
                                                           :segments [{:text [builtin.foldfunc]
                                                                       :click "v:lua.ScFa"}
                                                                      {:text ["%s"]
                                                                       :click "v:lua.ScSa"}
                                                                      {:text [builtin.lnumfunc
                                                                              " "]
                                                                       :click "v:lua.ScLa"}]})))})]
       :init (fn []
               (set vim.o.foldcolumn :1)
               (set vim.o.foldlevel 99)
               (set vim.o.foldenable true)
               (set vim.o.fillchars
                    "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"))
       :config true
       :opts {:provider_selector (fn []
                                   [:treesitter :indent])}})
