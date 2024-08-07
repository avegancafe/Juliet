(import-macros {: pack : key} :Juliet.macros)

(pack :natecraddock/workspaces.nvim
      {:dependencies [:Shatur/neovim-session-manager
                      :nvim-telescope/telescope.nvim]
       :keys [(key :<leader>sl ":Telescope workspaces<cr>"
                   "Load workspace session")]
       :lazy false
       :config (fn []
                 (local session-manager (require :session_manager))
                 (let [workspaces (require :workspaces)]
                   (workspaces.setup {:hooks {:open_pre (fn []
                                                          (local lines
                                                                 (require :tabby.feature.lines))
                                                          (local raw-tabs
                                                                 ((. (lines.get_line)
                                                                     :tabs)))
                                                          (local tabs [])
                                                          (raw-tabs.foreach (fn [tab]
                                                                              (if (not= (tab.name)
                                                                                        "[No Name]")
                                                                                  (table.insert tabs
                                                                                                tab))))
                                                          (if (> (length tabs)
                                                                 0)
                                                              (session-manager.save_current_session))
                                                          true)
                                              :open [(fn []
                                                       (local command
                                                              (if (= (vim.api.nvim_buf_get_name 0)
                                                                     "")
                                                                  (do
                                                                    (print "Empty buffer found when loading workspace session")
                                                                    (.. "tabNext | :q | SessionManager load_current_dir_session"))
                                                                  (.. "SessionManager load_current_dir_session")))
                                                       (vim.cmd command))]}})
                   (let [dirs (workspaces.get)
                         add-workspace (lambda [name path]
                                         (if (not (accumulate [found false _ dir (ipairs dirs)]
                                                    (or found (= dir.name name))))
                                             (workspaces.add path name)))]
                     (add-workspace :config "~/.config/Juliet")
                     (if (not (accumulate [found false _ dir (ipairs dirs)]
                                (or found
                                    (dir.path:match (.. ".*" :workspace ".*")))))
                         (workspaces.add_dir "~/workspace")))
                   (workspaces.sync_dirs)))})
