(import-macros {: pack} :macros)

(pack :j-hui/fidget.nvim
      {:config true
       :opts {:text {:spinner :dots :done "✓"} :timer {:spinner_rate 50}}})
