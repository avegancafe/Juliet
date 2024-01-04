(import-macros {: pack} :Juliet.macros)

(pack :Yggdroot/indentLine
      {:config (fn []
                 (vim.cmd "autocmd TermOpen * IndentLinesDisable")
                 (set vim.g.indentLine_fileTypeExclude
                      [:alpha :fennel :mason :term])
                 (set vim.g.indentLine_concealcursor :n)
                 (set vim.g.indentLine_char_list ["|" "¦" "┆" "┊"])
                 (set vim.g.vim_json_conceal 0)
                 (set vim.markdown_syntax_conceal 0))})
