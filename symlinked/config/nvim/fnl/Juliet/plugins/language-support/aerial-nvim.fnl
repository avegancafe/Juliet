(import-macros {: pack } :Juliet.macros)

(pack :stevearc/aerial.nvim {:dependencies [:nvim-treesitter/nvim-treesitter
                                            :vim-tree/nvim-web-devicons]
                             :event :VeryLazy
                             :opts {}})
