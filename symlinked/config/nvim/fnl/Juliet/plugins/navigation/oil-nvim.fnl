(import-macros {: pack : key} :Juliet.macros)

(fn open-oil [path]
  (vim.cmd "vsplit | wincmd H | vertical resize 40")
  (let [oil (require :oil)] (oil.open path)))

(pack :stevearc/oil.nvim
      {:keys [(key :<leader>f
                   (fn []
                     (open-oil (os.capture "git rev-parse --show-toplevel")))
                   "Open file explorer")
              (key :<leader>ff
                   (fn []
                     (open-oil (vim.fn.expand "%:p:h")))
                   "Open file explorer in current directory")]
       :lazy false
       :opts {:view_options {:show_hidden true}
              :float {:max_width 120 :max_height 30}
              :keymaps {:<c-t> {1 :actions.select :opts {:tab true}}
                        :<c-c> ":q<cr>"
