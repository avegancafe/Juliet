(import-macros {: pack} :themis.pack.lazy)

[(pack :williamboman/mason.nvim
       {:config (fn []
                  (local mason (require :mason))
                  (mason.setup {:ui {:border :rounded :width 0.6 :height 0.7}})
                  (vim.cmd "autocmd FileType mason setlocal winblend=10")
                  (vim.api.nvim_create_autocmd [:BufEnter :BufWinEnter]
                                               {:pattern :*.yml
                                                :callback (fn []
                                                            (vim.diagnostic.hide))}))})
 (pack :williamboman/mason-lspconfig.nvim {})
 (pack :neovim/nvim-lspconfig {})
 (pack :onsails/lspkind.nvim {})
 (pack :ray-x/lsp_signature.nvim {:config true})]
