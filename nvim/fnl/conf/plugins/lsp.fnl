(import-macros {: pack} :themis.pack.lazy)

[(pack :williamboman/mason.nvim
       {:config true :opts {:ui {:border :rounded :width 0.6 :height 0.7}}})
 (pack :williamboman/mason-lspconfig.nvim {})
 (pack :neovim/nvim-lspconfig {})
 (pack :onsails/lspkind.nvim {})]
