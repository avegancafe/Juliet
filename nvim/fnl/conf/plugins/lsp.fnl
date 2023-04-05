(import-macros {: pack} :themis.pack.lazy)

[(pack :williamboman/mason.nvim {:config true :opts {:ui {:border :rounded}}})
 (pack :williamboman/mason-lspconfig.nvim {})
 (pack :neovim/nvim-lspconfig {})
 (pack :onsails/lspkind.nvim {})]
