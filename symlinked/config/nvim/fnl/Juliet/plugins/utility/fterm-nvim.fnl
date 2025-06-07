(import-macros {: pack : key} :Juliet.macros)

(pack :numToStr/FTerm.nvim
      {:keys [(key :<leader>t
                   (fn []
                     ((. (require :FTerm) :toggle)))
                   "Toggle terminal")
              (key :<c-h>
                   (fn []
                     ((. (require :FTerm) :close)))
                   "Toggle terminal" {:mode :t})
              (key :<leader>j
                   (fn []
                     (local ft (require :FTerm))
                     (local btop-term (ft:new {:ft :fterm_btop :cmd :btop}))
                     (btop-term:toggle)) :btop)]
       :opts {:border :rounded :dimensions {:width 0.9 :height 0.9}}})
