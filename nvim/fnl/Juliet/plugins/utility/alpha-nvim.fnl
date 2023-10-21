(import-macros {: pack} :Juliet.macros)

(pack :goolord/alpha-nvim
      {:dependencies [:kyazdani42/nvim-web-devicons]
       :config (fn []
                 (var alpha (require :alpha))
                 (var dashboard (require :alpha.themes.dashboard))
                 (set dashboard.section.header.val
                      ["    ___     "
                       "   |\\  \\    "
                       "   \\ \\  \\   "
                       " __ \\ \\  \\  "
                       "|\\  \\\\_\\  \\ "
                       "\\ \\________\\"
                       " \\|________|"
                       "            "])
                 (set dashboard.section.buttons.val
                      [(dashboard.button :s " > Open session"
                                         ":Telescope workspaces<cr>")
                       (dashboard.button :e " > Explore fs"
                                         ":lua require('mini.files').open()<cr>")
                       (dashboard.button :l " > Load session for current dir"
                                         ":SessionManager load_current_dir_session<cr>")
                       (dashboard.button :f " > Find file" ":Pick files<cr>")])
                 (local fortune (require :alpha.fortune))
                 (set dashboard.section.footer.val (fortune))
                 (alpha.setup dashboard.config)
                 )})
