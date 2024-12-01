(import-macros {: pack} :Juliet.macros)

(pack :avegancafe/peek.nvim {:event :VeryLazy
                             :build "deno task --quiet build:fast"
                             :init (fn []
                                     (local peek (require :peek))
                                     (vim.api.nvim_create_user_command :PeekOpen
                                                                       peek.open
                                                                       {})
                                     (vim.api.nvim_create_user_command :PeekClose
                                                                       peek.close
                                                                       {}))
                             :opts {}})
