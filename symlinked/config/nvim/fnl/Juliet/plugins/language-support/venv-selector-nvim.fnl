(import-macros {: pack} :Juliet.macros)

(fn shorten-pipenv-path [filename]
  (: (filename:gsub (.. (os.getenv :HOME) :/.local/share/virtualenvs/) "")
     :gsub :/bin/python ""))

(pack :linux-cultist/venv-selector.nvim
      {:dependencies [:neovim/nvim-lspconfig
                      :nvim-telescope/telescope.nvim
                      :mfussenegger/nvim-lint]
       :branch :regexp
       :opts {:settings {:options {:debug true
                                   :on_venv_activate_callback (fn []
                                                                (let [lint (require :lint)]
                                                                  (lint.try_lint nil
                                                                                 {:ignore_errors true})))}
                         :search {:virtualenvs false
                                  :pyenv false
                                  :hatch false
                                  :anaconda_base false
                                  :anaconda_envs false
                                  :poetry false
                                  :pipx false
                                  :cwd false
                                  :workspace false
                                  :pipenv {:command "fd '/bin/python$' ~/.local/share/virtualenvs/ --full-path"
                                           :on_telescope_result_callback shorten-pipenv-path}}}}
       :lazy false})
