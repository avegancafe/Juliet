(fn vim.g.__juliet_fold_text []
  (print " v  ")
  (let [line (vim.fn.getline vim.v.foldstart)
        lines-count (+ vim.v.foldend (- vim.v.foldstart) 1)
        fill-count (- (vim.fn.winwidth "%") (length line)
                      (length (.. "" lines-count)) 14)]
    (.. line " " (string.rep "-" fill-count) " (" lines-count " L) --")))

(vim.cmd "set foldtext=__juliet_fold_text()")
(set vim.opt.fillchars "fold: ")
(set vim.opt.foldmethod :expr)
(set vim.opt.foldlevelstart 99)
