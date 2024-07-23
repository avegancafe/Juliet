(import-macros {: pack} :Juliet.macros)

(pack :MeanderingProgrammer/markdown.nvim
      {:opts {:heading {:icons [" 󰉫 " "  󰉬 " "   󰉭 " "    󰉮 " "     󰉯 " "      󰉰 "]}}
       :dependencies [:nvim-treesitter/nvim-treesitter
                      :nvim-tree/nvim-web-devicons]})
