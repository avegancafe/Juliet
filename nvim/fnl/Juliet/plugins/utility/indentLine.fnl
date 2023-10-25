(import-macros {: pack} :Juliet.macros)

(pack :Yggdroot/indentLine
      {:config (fn []
                 (vim.cmd "autocmd TermOpen * IndentLinesDisable")
                 (tset vim.g :indentLine_fileTypeExclude
                       [:alpha :fennel :mason :term])
                 (tset vim.g :indentLine_concealcursor :n)
                 (tset vim.g :indentLine_char_list ["|" "¦" "┆" "┊"]))})
