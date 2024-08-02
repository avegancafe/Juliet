(import-macros {: pack : key} :Juliet.macros)

(pack :nvim-telescope/telescope.nvim
      {:dependencies [:nvim-tree/nvim-web-devicons
                      :nvim-telescope/telescope-ui-select.nvim
                      :nvim-lua/plenary.nvim
                      :ribru17/bamboo.nvim
                      :natecraddock/workspaces.nvim]
       :lazy false
       :keys [(key :<c-p> ":Telescope find_files<cr>" "Fuzzy find a file")
              (key :<leader>p ":Telescope find_files<cr>" "Fuzzy find a file")
              (key :<c-g> ":Telescope live_grep<cr>" "Live grep")
              (key :<c-b> ":Telescope buffers<cr>" "Fuzzy list buffers")]
       :config (fn []
                 (let [actions (require :telescope.actions)
                       trouble (require :trouble.sources.telescope)
                       telescope (require :telescope)]
                   (telescope.setup {:defaults {:mappings {:i {:<c-j> actions.move_selection_next
                                                               :<c-k> actions.move_selection_previous
                                                               :<esc> actions.close
                                                               :<c-o> trouble.open
                                                               :<enter> actions.select_tab
                                                               :<c-b> actions.select_default}}
                                                :path_display {:shorten {:len 3
                                                                         :exclude [-1
                                                                                   -2]}}
                                                :theme :ivy
                                                :layout_config {:prompt_position :bottom}
                                                :layout_strategy :bottom_pane}
                                     :pickers {:find_files {:find_command [:fd
                                                                           :--hidden
                                                                           :--no-follow
                                                                           :--no-ignore
                                                                           :--ignore-file
                                                                           (vim.fn.expand :$HOME/.gitignore_global)
                                                                           :--type
                                                                           :file]}
                                               :live_grep {:file_ignore_patterns [:node_modules
                                                                                  :.git$]
                                                           :find_command :rg
                                                           :additional_args (fn []
                                                                              [:--no-heading
                                                                               :--with-filename
                                                                               :--line-number
                                                                               :--column
                                                                               :--hidden
                                                                               :--smart-case])}
                                               :buffers {:mappings {:i {:<c-q> (+ actions.delete_buffer
                                                                                  actions.move_to_top)}}}}})
                   (telescope.load_extension :ui-select)
                   (telescope.load_extension :workspaces)))})
