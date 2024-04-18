(import-macros {: pack} :Juliet.macros)

(pack :rcarriga/nvim-notify {:init (fn []
                                     (tset vim :notify
                                           (fn [msg ...]
                                             (if (not (= msg
                                                         "The 'nightly' branch for Neogit provides support for nvim-0.10"))
                                                 (let [notify (require :notify)]
                                                   (notify msg ...))))))
                             :opts {:timeout 5000 :stages :static}
                             :config true})
