(import-macros {: pack} :Juliet.macros)
(pack :jackMort/ChatGPT.nvim
      {:event :VeryLazy
       :opts {}
       :dependencies [:MunifTanjim/nui.nvim
                      :nvim-lua/plenary.nvim
                      :nvim-telescope/telescope.nvim]})
