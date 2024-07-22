(import-macros {: pack} :Juliet.macros)

(pack :folke/which-key.nvim
      {:config true
       :dependencies [:nvim-tree/nvim-web-devicons]
       :opts {:icons {:separator "->"}
              :win {:border :rounded}
              :triggers {1 :<auto> 2 {:mode :nisotc}}}})
