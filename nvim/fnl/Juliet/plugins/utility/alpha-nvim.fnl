(import-macros {: pack} :Juliet.macros)

(pack :goolord/alpha-nvim
      {:dependencies [:kyazdani42/nvim-web-devicons]
       :config (fn []
                 (var alpha (require :alpha))
                 (var dashboard (require :alpha.themes.dashboard))
                 (set dashboard.section.header.val
                      ["    ↑↑↓↓    "
                       "   ←→←→AB   "
                       "   ┌────┐   "
                       "   │    ├┐  "
                       "   │┌ ┌ └│  "
                       "   │ ╘  └┘  "
                       "   │    │   "
                       "   │╙─  │   "
                       "   │    │   "
                       "   └──┘ │   "
                       "     │  │   "
                       "     │  │   "])
                 (set dashboard.section.buttons.val
                      [(dashboard.button :l
                                         " > Load session for current directory"
                                         ":SessionManager load_current_dir_session<cr>")
                       (dashboard.button :f " > Find file"
                                         ":Telescope find_files<cr>")
                       (dashboard.button :e " > Explore fs"
                                         ":lua require('mini.files').open()<cr>")
                       (dashboard.button :s " > Open session"
                                         ":Telescope workspaces<cr>")])
                 (alpha.setup dashboard.config))})
