(import-macros {: pack} :themis.pack.lazy)

(pack :folke/todo-comments.nvim
      {:dependencies [:nvim-lua/plenary.nvim]
       :config true
       :opts {:keywords {:FIX {:color :warning}}
              :WARN {:alt :EDIT}
              :highlight {:pattern ".*(KEYWORDS)*" :keyword :bg}
              :search {:pattern ".*<(KEYWORDS).*/>"}}})
