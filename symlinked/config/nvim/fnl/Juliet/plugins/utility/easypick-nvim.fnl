(import-macros {: pack} :Juliet.macros)

(pack :axkirillov/easypick.nvim
      {:dependencies [:nvim-telescope/telescope.nvim]
       :init (fn []
               (vim.cmd ":command! EditChangedFiles Easypick changed-files"))
       :opts {:pickers [{:name :changed-files
                         :command "git status --short | awk '{ print $2 }'"}]}})
