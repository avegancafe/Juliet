(import-macros {: pack} :Juliet.macros)

(pack :rcarriga/nvim-notify {:init (fn [] (tset vim :notify (require :notify)))
                             :opts {:timeout 5000 :stages :static}
                             :config true})
