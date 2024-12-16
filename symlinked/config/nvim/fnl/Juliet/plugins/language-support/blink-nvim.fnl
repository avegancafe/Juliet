(import-macros {: pack} :Juliet.macros)

(pack :Saghen/blink.cmp
      {:lazy false
       :version :0.7.6
       :opts {:completion {:documentation {:auto_show true}}
              :keymap {:<CR> [:select_and_accept :fallback]
                       :<C-k> [:show :show_documentation :hide_documentation]}}})
