(import-macros {: pack : key} :Juliet.macros)

(pack :stevearc/oil.nvim
      {:keys [(key :<leader>f
                   (fn []
                     (local oil (require :oil))
                     (oil.open_float (os.capture "git rev-parse --show-toplevel")))
                   "Open file explorer")
              (key :<leader>ff ":Oil --float %:p:h<cr>"
                   "Open file explorer in current directory")]
       :lazy false
       :opts {:view_options {:show_hidden true}
              :float {:max_width 120 :max_height 30}}})
