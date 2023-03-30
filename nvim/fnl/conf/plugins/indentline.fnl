(import-macros {: pack} :themis.pack.lazy)

(pack :Yggdroot/indentLine
      {:config (fn []
                 (tset vim.g :indentLine_fileTypeExclude [:dashboard])
                 (tset vim.g :indentLine_concealcursor :n))})
