(import-macros {: pack} :Juliet.macros)

(pack :rachartier/tiny-inline-diagnostic.nvim
      {:event :VeryLazy
       :priority 1000
       :opts {:options {:show_source true :throttle 0 :enable_on_insert true}}
       :init (fn [] (vim.diagnostic.config {:virtual_text false}))})
