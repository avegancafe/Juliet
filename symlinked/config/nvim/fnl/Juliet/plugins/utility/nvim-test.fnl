(import-macros {: pack : key} :Juliet.macros)

(pack :klen/nvim-test
      {:opts {}
       :keys [(key :<leader>ft ":TestLast<cr>" "Run tests for current file")
              (key :<leader>ftt ":TestFile<cr>" "Run tests for current file")
              (key :<leader>ftl ":TestLast<cr>" "Run last test command")
              (key :<leader>ftn ":TestNearest<cr>" "Run nearest test")
              (key :<leader>fts ":TestSuite<cr>" "Run test suite")]
       :init (fn []
               (let [pytest (require :nvim-test.runners.pytest)
                     jest (require :nvim-test.runners.jest)
                     homedir (os.getenv :HOME)]
                 (jest:setup {:command (.. homedir :/.nodenv/shims/npm)
                              :args [:test]})
                 (pytest:setup {:command (.. homedir
                                             :/workspace/dev-env/bin/j2-test)})))})
