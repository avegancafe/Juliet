(import-macros {: pack} :Juliet.macros)

(pack :j-hui/fidget.nvim
      {:config true
       :tag :legacy
       :opts {:text {:spinner :dots :done "✓"} :timer {:spinner_rate 50}}})
