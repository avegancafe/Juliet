(import-macros {: pack : key} :Juliet.macros)

(pack :glepnir/dashboard-nvim
      {:keys [(key :<leader>h ":Dashboard<cr>" :Home)]
       :config (fn []
                 (let [utils (require :telescope.utils)
                       dashboard (require :dashboard)
                       get-fortune (fn []
                                     (let [socket (io.popen :fortune)
                                           fortune (socket:read :*a)
                                           footer []]
                                       (socket:close)
                                       (each [_ value (fortune:gmatch "[^\r\n]+")]
                                         (table.insert footer value))
                                       footer))
                       get-dashboard-git-status (fn []
                                                  (let [git-cmd [:git
                                                                 :status
                                                                 :-s
                                                                 "--"
                                                                 "."]
                                                        output (utils.get_os_command_output git-cmd)]
                                                    (if (= #output 0)
                                                        (get-fortune)
                                                        [""
                                                         ""
                                                         "Git status"
                                                         ""
                                                         (unpack output)])))
                       is_worktree (utils.get_os_command_output [:git
                                                                 :rev-parse
                                                                 :--is-inside-work-tree]
                                                                (vim.loop.cwd))]
                   (var custom-footer [])
                   (if (= (. is_worktree 1) :true)
                       (set custom-footer (get-dashboard-git-status))
                       (set custom-footer (get-fortune)))
                   (dashboard.setup {:theme :doom
                                     :config {:header ["            "
                                                       "            "
                                                       "    ↑↑↓↓    "
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
                                                       "     │  │   "
                                                       "            "
                                                       "            "
                                                       "            "]
                                              :footer custom-footer
                                              :packages {:enable false}
                                              :mru {:limit 5}
                                              :shortcut [{:desc "Last session"
                                                          :key :l
                                                          :group :DashboardMruTitle
                                                          :action "SessionManager load_current_dir_session"}
                                                         {:desc "Find file"
                                                          :key :f
                                                          :group :DashboardMruTitle
                                                          :action "Telescope find_files"}
                                                         {:desc "Open project"
                                                          :key :p
                                                          :group :DashboardMruTitle
                                                          :action "Telescope live_grep"}]
                                              :center [{:desc "Last Session"
                                                        :icon " "
                                                        :key :l
                                                        :action "SessionManager load_current_dir_session"}
                                                       {:desc "Find file"
                                                        :icon " "
                                                        :key :f
                                                        :action "Telescope find_files"}
                                                       {:desc "Open changed files"
                                                        :icon " "
                                                        :key :c
                                                        :action "call v:lua.EditChangedFiles()"}
                                                       {:desc "Open project"
                                                        :icon " "
                                                        :key :p
                                                        :action "Telescope workspaces"}]}})))})
