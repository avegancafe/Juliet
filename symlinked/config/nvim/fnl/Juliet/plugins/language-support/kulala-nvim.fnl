(import-macros {: pack : key} :Juliet.macros)

(pack :mistweaverco/kulala.nvim
      {:keys [(key :<leader>er
                   (fn []
                     (let [kulala (require :kulala)]
                       (kulala.run)))
                   "Execute http request on current line in .http file")]
       :lazy false
       :opts {:default_view :headers_body}})
