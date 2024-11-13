(import-macros {: pack} :Juliet.macros)

(pack :rcarriga/nvim-notify {:init (fn []
                                     (tset vim :notify
                                           (fn [msg ...]
                                             (let [banned-msgs ["The 'nightly' branch for Neogit provides support for nvim-0.10"
                                                                "No information available"]]
                                               (local should-skip
                                                      (accumulate [agg false _ banned-msg (ipairs banned-msgs)]
                                                        (or agg
                                                            (= msg banned-msg))))
                                               (if (not should-skip)
                                                   (let [notify (require :notify)]
                                                     (notify msg ...)))))))
                             :opts {:timeout 5000 :stages :static}
                             :config true})
