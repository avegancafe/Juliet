(import-macros {: pack : key} :Juliet.macros)

(pack :axkirillov/easypick.nvim
      {:dependencies [:nvim-telescope/telescope.nvim]
       :init (fn []
               (vim.cmd ":command! EditChangedFiles Easypick changed-files"))
       :lazy false
       :keys [(key :<leader>gt ":Easypick git-ticket<cr>")
              "Switch to another Jira ticket's branch"]
       :opts {:pickers [{:name :changed-files
                         :command "git status --short | awk '{ print $2 }'"}
                        {:name :git-ticket
                         :command :my-active-tickets
                         :action (fn [buff-number]
                                   (let [action-state (require :telescope.actions.state)
                                         actions (require :telescope.actions)]
                                     (actions.select_default:replace (fn []
                                                                       (actions.close buff-number)
                                                                       (local selection
                                                                              (. (action-state.get_selected_entry)
                                                                                 1))
                                                                       (os.execute (.. "switch-to-ticket '"
                                                                                       selection
                                                                                       "'")))))
                                   true)}]}})
