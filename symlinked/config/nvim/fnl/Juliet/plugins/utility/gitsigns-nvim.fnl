(import-macros {: pack} :Juliet.macros)

(pack :lewis6991/gitsigns.nvim
      {:dependencies [:nvim-lua/plenary.nvim]
       :opts {:current_line_blame true
              :current_line_blame_formatter "<author_time:%Y-%m-%d> - <summary>"}})
