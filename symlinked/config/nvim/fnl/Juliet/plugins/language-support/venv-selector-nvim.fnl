(import-macros {: pack} :Juliet.macros)

(pack :linux-cultist/venv-selector.nvim
      {:dependencies [:neovim/nvim-lspconfig :nvim-telescope/telescope.nvim]
       :branch :regexp
       :opts {:settings {:options {:debug true}
                         :search {:virtualenvs false
                                  :pyenv false
                                  :hatch false
                                  :anaconda_base false
                                  :anaconda_envs false
                                  :poetry false
                                  :pipx false
                                  :cwd false
                                  :workspace false
                                  :pipenv {:command "fd '/bin/python$' ~/.local/share/virtualenvs/ --full-path"}}}}
       :lazy false})
