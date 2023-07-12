(import-macros {: pack : key} :macros)
(pack :echasnovski/mini.files
      {:version false
       :config true
       :opts {:windows {:preview true}}
       :init (fn []
               (vim.api.nvim_create_autocmd :User
                                            {:callback (fn [args]
                                                         (local win-id
                                                                args.data.win_id)
                                                         (vim.api.nvim_win_set_config win-id
                                                                                      {:border :rounded}))
                                             :pattern :MiniFilesWindowOpen}))
       :keys [(key :<leader>f
                   (fn []
                     (let [f (require :mini.files)] (f.open)))
                   "Toggle file")
              (key :<leader>ff
                   (fn []
                     (let [f (require :mini.files)]
                       (f.open (vim.api.nvim_buf_get_name 0))))
                   "Find file in nvim-tree")
              (key :<leader>fr (fn []
                                 (let [f (require :mini.files)]
                                   (f.refresh)))
                   "Refresh nvim-tree")]})
