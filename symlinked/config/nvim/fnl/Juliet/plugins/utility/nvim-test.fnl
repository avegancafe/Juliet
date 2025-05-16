(import-macros {: pack : key} :Juliet.macros)

(pack :klen/nvim-test
      {:opts {:termOpts {:go_back true}}
       :keys [(key :<leader>ft ":TestFile<cr>")
              (key :<leader>ftt ":TestFile<cr>")
              (key :<leader>ftn ":TestNearest<cr>")
              (key :<leader>fts ":TestSuite<cr>")]
       :init (fn []
               (let [pytest (require :nvim-test.runners.pytest)
                     homedir (os.getenv :HOME)]
                 (pytest:setup {:command (.. homedir
                                             :/workspace/dev-env/bin/j2-test)})))})
