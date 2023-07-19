(import-macros {: pack} :Juliet.macros)

(pack :natecraddock/workspaces.nvim
      {:dependencies [:Shatur/neovim-session-manager
                      :nvim-telescope/telescope.nvim]
       :config (fn []
                 (let [workspaces (require :workspaces)]
                   (workspaces.setup {:hooks {:open_pre (fn []
                                                          (let [session-manager (require :session_manager)]
                                                            (session-manager.save_current_session)))
                                              :open (fn []
                                                      (let [session-manager (require :session_manager)]
                                                        (session-manager.load_current_dir_session)))}})
                   ((. (require :telescope) :load_extension) :workspaces)
                   (let [dirs (workspaces.get)
                         add-workspace (lambda [name path]
                                         (if (not (accumulate [found false _ dir (ipairs dirs)]
                                                    (or found (= dir.name name))))
                                             (workspaces.add name path)))]
                     (add-workspace :config "~/.config/Juliet")
                     (if (not (accumulate [found false _ dir (ipairs dirs)]
                                (or found
                                    (dir.path:match (.. ".*" :workspace ".*")))))
                         (workspaces.add_dir "~/workspace")))
                   (workspaces.sync_dirs)))})
