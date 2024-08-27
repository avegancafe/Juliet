(import-macros {: pack} :Juliet.macros)

(pack :avegancafe/alpha-nvim
      {:dependencies [:nvim-tree/nvim-web-devicons]
       :branch :fix-close-on-new-tab-bug
       :config (fn []
                 (var alpha (require :alpha))
                 (var dashboard (require :alpha.themes.dashboard))
                 (set dashboard.config.close_on_tabnew true)
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
                       (dashboard.button :e " > Explore fs" ":Neotree<cr>")
                       (dashboard.button :l " > Load session for current dir"
                                         ":SessionManager load_current_dir_session<cr>")
                       (dashboard.button :f " > Find file" ":Pick files<cr>")])
                 (local fortune (require :alpha.fortune))
                 (set dashboard.section.footer.val (fortune))
                 (alpha.setup dashboard.config))})
