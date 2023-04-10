(import-macros {: pack} :themis.pack.lazy)

[(pack :williamboman/mason.nvim
       {:config true :opts {:ui {:border :rounded :width 0.6 :height 0.7}}
       :config (fn []
                 (local mason (require :mason))
                 (mason.setup {:ui {:border :rounded :width 0.6 :height 0.7}})
                 (vim.cmd "autocmd FileType mason setlocal winblend=10")
                 )})
 (pack :williamboman/mason-lspconfig.nvim {})
 (pack :neovim/nvim-lspconfig {})
 (pack :onsails/lspkind.nvim {})
 (pack :Fildo7525/pretty_hover {:config true})]
