(import-macros {: pack} :themis.pack.lazy)

(pack :Yggdroot/indentLine
      {:config (fn []
                 (tset vim.g :indentLine_fileTypeExclude [:dashboard :fennel])
                 (tset vim.g :indentLine_concealcursor :n))})
