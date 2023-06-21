(import-macros {: pack} :macros)

(pack :Shatur/neovim-session-manager
      {:config (fn []
                 (let [session-manager (require :session_manager)
                       config (require :session_manager.config)]
                   (session-manager.setup {:autoload_mode config.AutoloadMode.Disabled
                                           :max_path_length 0})))})
