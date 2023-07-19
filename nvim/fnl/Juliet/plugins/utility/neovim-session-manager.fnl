(import-macros {: pack : key} :Juliet.macros)

(pack :Shatur/neovim-session-manager
      {:keys [(key :<leader>ss ":SessionManager save_current_session<cr>"
                   "Save current session" {:silent false})
              (key :<leader>sl ":Telescope workspaces<cr>" "Load workspace session")]
       :config (fn []
                 (let [session-manager (require :session_manager)
                       config (require :session_manager.config)]
                   (session-manager.setup {:autoload_mode config.AutoloadMode.Disabled
                                           :max_path_length 0})))})
