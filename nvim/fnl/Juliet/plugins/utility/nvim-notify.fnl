(import-macros {: pack} :Juliet.macros)

(pack :rcarriga/nvim-notify
      {:init (fn [] (tset vim :notify (require :notify)))})
