(import-macros {: pack : key} :Juliet.macros)

(pack :numToStr/FTerm.nvim
      {:keys [(key :<leader>t
                   (fn []
                     ((. (require :FTerm) :toggle)))
                   "Toggle terminal")
              (key :<c-h>
                   (fn []
                     ((. (require :FTerm) :toggle)))
                   "Toggle terminal" {:mode :t})]
       :opts {:border :rounded :dimensions {:width 0.9 :height 0.9}}})