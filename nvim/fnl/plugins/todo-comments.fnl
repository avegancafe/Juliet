(import-macros {: pack} :macros)

(pack :folke/todo-comments.nvim
      {:dependencies [:nvim-lua/plenary.nvim]
       :config true
       :opts {:keywords {:FIX {:color :warning}}
              :WARN {:alt :EDIT}
              ; implement custom highlight/search regexp if necessary
              ; :highlight {:pattern ".*(KEYWORDS)*" :keyword :bg}
              ; :search {:pattern ".*<(KEYWORDS).*/>"}
              }})
