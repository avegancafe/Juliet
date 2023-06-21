(import-macros {: pack} :macros)

[(pack :williamboman/mason.nvim
       {:dependencies [:williamboman/mason-lspconfig.nvim]
        :config (fn []
                  (local mason (require :mason))
                  (mason.setup {:ui {:border :rounded :width 0.6 :height 0.7}})
                  (vim.cmd "autocmd FileType mason setlocal winblend=10")
                  (vim.api.nvim_create_autocmd [:BufEnter :BufWinEnter]
                                               {:pattern :*.yml
                                                :callback (fn []
                                                            (vim.diagnostic.hide))}))})
 :neovim/nvim-lspconfig
 :onsails/lspkind.nvim
 (pack :ray-x/lsp_signature.nvim {:config true})]
