(import-macros {: pack} :Juliet.macros)
(pack :m4xshen/hardtime.nvim
      {:dependencies [:MunifTanjim/nui.nvim :nvim-lua/plenary.nvim]
       :opts {:max_time 0 :disabled_filetypes [:minifiles]}})
