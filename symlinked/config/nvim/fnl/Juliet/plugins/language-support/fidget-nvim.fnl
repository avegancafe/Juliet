(import-macros {: pack} :Juliet.macros)

(pack :j-hui/fidget.nvim {:config true
                          :opts {:notification {:window {:winblend 0
                                                         :border :none}}
                                 :progress {:display {:done_icon "✓"}}}})
