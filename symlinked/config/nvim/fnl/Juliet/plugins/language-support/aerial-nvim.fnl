(import-macros {: pack : key} :Juliet.macros)

(pack :stevearc/aerial.nvim {:dependencies [:nvim-treesitter/nvim-treesitter
                                            :vim-tree/nvim-web-devicons]
                             :keys [(key :<leader>do :<cmd>AerialToggle<cr>
                                         "Toggle LSP outline")]
                             :opts {}})
