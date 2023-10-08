(import-macros {: pack : key} :Juliet.macros)

(pack :nvim-telescope/telescope.nvim
      {:keys [(key :<c-p>
                   (fn []
                     (let [f (require :mini.files)]
                       (f.close)
                       (vim.cmd "Telescope find_files")))
                   "Fuzzy find a file")
              (key :<c-b> ":Telescope buffers<cr>")
              "Fuzzy list buffers"]
       :lazy false
       :dependencies [:kyazdani42/nvim-web-devicons
                      :nvim-telescope/telescope-ui-select.nvim
                      :nvim-lua/plenary.nvim
                      :ribru17/bamboo.nvim
                      :natecraddock/workspaces.nvim]
       :config (fn []
                 (let [actions (require :telescope.actions)
                       trouble (require :trouble.providers.telescope)
                       telescope (require :telescope)
                       colors (require :bamboo.colors)]
                   (vim.api.nvim_set_hl 0 :TelescopeResultsBorder
                                        {:fg colors.grey})
                   (vim.api.nvim_set_hl 0 :TelescopePromptBorder
                                        {:fg colors.grey})
                   (vim.api.nvim_set_hl 0 :TelescopePreviewBorder
                                        {:fg colors.grey})
                   (telescope.setup {:defaults {:mappings {:i {:<c-j> actions.move_selection_next
                                                               :<c-k> actions.move_selection_previous
                                                               :<esc> actions.close
                                                               :<c-o> trouble.open_with_trouble
                                                               :<enter> actions.select_tab
                                                               :<c-b> actions.select_default}}
                                                :layout_config {:prompt_position :bottom}
                                                :path_display {:shorten {:len 3
                                                                         :exclude [-1
                                                                                   -2]}}}
                                     :pickers {:find_files {:find_command [:fd
                                                                           :--hidden
                                                                           :--glob
                                                                           ""
                                                                           :--type
                                                                           :file]}
                                               :live_grep {:file_ignore_patterns [:node_modules
                                                                                  :.git$]
                                                           :theme :ivy
                                                           :layout_config {:prompt_position :bottom}
                                                           :layout_strategy :bottom_pane
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
