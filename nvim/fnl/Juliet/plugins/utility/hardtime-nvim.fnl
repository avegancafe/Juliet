(import-macros {: pack} :Juliet.macros)
(pack :m4xshen/hardtime.nvim
      {:dependencies [:MunifTanjim/nui.nvim :nvim-lua/plenary.nvim]
       :opts {:disabled_filetypes [:minifiles]}})
