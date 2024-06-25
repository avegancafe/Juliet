(import-macros {: pack} :Juliet.macros)

(pack :linux-cultist/venv-selector.nvim
      {:dependencies [:neovim/nvim-lspconfig :nvim-telescope/telescope.nvim]
       :branch :regexp
       :opts {:settings {:search {:find_pipenv_venvs {:command "fd '/bin/python$' ~/.local/share/virtualenvs/ --full-path"}}}}
       :lazy false})
