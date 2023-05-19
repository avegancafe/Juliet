(import-macros {: pack} :macros)

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
                   ((. (require :telescope) :load_extension) :workspaces)))})
