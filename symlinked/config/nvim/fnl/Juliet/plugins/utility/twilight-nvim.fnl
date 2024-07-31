(import-macros {: pack} :Juliet.macros)

(pack :folke/twilight.nvim
      {:opts {:context 5
              :expand [:function
                       :method
                       :table
                       :if_statement
                       :function_definition]}})
