(import-macros {: pack} :Juliet.macros)

(pack :Yggdroot/indentLine
      {:config (fn []
                 (tset vim.g :indentLine_fileTypeExclude
                       [:alpha :fennel :mason])
                 (tset vim.g :indentLine_concealcursor :n)
                 (tset vim.g :indentLine_char_list ["|" "¦" "┆" "┊"]))})
