(import-macros {: pack : key} :Juliet.macros)

(pack :nvim-telescope/telescope.nvim
      {:dependencies [:nvim-tree/nvim-web-devicons
                      :nvim-telescope/telescope-ui-select.nvim
                      :nvim-lua/plenary.nvim
                      :ribru17/bamboo.nvim
                      :natecraddock/workspaces.nvim]
       :lazy false
       :keys [(key :<c-p>
                   (fn []
                     (let [builtin (require :telescope.builtin)]
                       (builtin.find_files {:layout_config {:width 120}})))
                   "Fuzzy find a file")
              (key :<leader>p
                   (fn []
                     (let [builtin (require :telescope.builtin)]
                       (builtin.find_files {:layout_config {:width 120}})))
                   "Fuzzy find a file")
              (key :<c-g> (fn []
                            (let [builtin (require :telescope.builtin)]
                              (builtin.live_grep)))
                   "Live grep")
              (key :<c-b> (fn []
                            (let [builtin (require :telescope.builtin)]
                              (builtin.buffers {:layout_config {:width 120}})))
                   "Fuzzy list buffers")]
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
                                                                                   -2]}}}
                                     :pickers {:find_files {:find_command [:fd
                                                                           :--hidden
                                                                           :--no-follow
                                                                           :--no-ignore
                                                                           :--ignore-file
                                                                           (vim.fn.expand :$HOME/.gitignore_global)
                                                                           :--type
                                                                           :file]
                                                            :theme :dropdown}
                                               :live_grep {:file_ignore_patterns [:node_modules
                                                                                  :.git$]
                                                           :find_command :rg
                                                           :additional_args (fn []
                                                                              [:--no-heading
                                                                               :--with-filename
                                                                               :--line-number
                                                                               :--column
                                                                               :--hidden
                                                                               :--smart-case])
                                                           :theme :ivy
                                                           :layout_config {:prompt_position :bottom}
                                                           :layout_strategy :bottom_pane}
                                               :buffers {:theme :dropdown
                                                         :mappings {:i {:<c-q> (+ actions.delete_buffer
                                                                                  actions.move_to_top)}}}}})
                   (telescope.load_extension :ui-select)
                   (telescope.load_extension :workspaces)))})
