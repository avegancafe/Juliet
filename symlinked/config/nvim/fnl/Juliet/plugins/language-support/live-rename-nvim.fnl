(import-macros {: pack} :Juliet.macros)

(pack :saecki/live-rename.nvim
      {:opts {}
       :init (fn []
               (tset _G :LiveRename
                     (fn []
                       (let [live-rename (require :live-rename)]
                         (live-rename.rename {:insert true}))))
               (vim.cmd ":command! -nargs=0 LiveRename call v:lua.LiveRename()"))})
