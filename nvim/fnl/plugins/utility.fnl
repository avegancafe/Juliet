(import-macros {: pack} :macros)

[(pack :chentoast/marks.nvim {:config true})
 (pack :glepnir/dashboard-nvim
       {:event :VimEnter
        :config (fn []
                  (let [utils (require :telescope.utils)
                        dashboard (require :dashboard)
                        get-fortune (fn []
                                      (let [socket (io.popen :fortune)
                                            fortune (socket:read :*a)
                                            footer []]
                                        (socket:close)
                                        (each [_ value (fortune:gmatch "[^\r\n]+")]
                                          (table.insert footer value))
                                        footer))
                        get-dashboard-git-status (fn []
                                                   (let [git-cmd [:git
                                                                  :status
                                                                  :-s
                                                                  "--"
                                                                  "."]
                                                         output (utils.get_os_command_output git-cmd)]
                                                     (if (= #output 0)
                                                         (get-fortune)
                                                         [""
                                                          ""
                                                          "Git status"
                                                          ""
                                                          (unpack output)])))
                        is_worktree (utils.get_os_command_output [:git
                                                                  :rev-parse
                                                                  :--is-inside-work-tree]
                                                                 (vim.loop.cwd))]
                    (var custom-footer [])
                    (if (= (. is_worktree 1) :true)
                        (set custom-footer (get-dashboard-git-status))
                        (set custom-footer (get-fortune)))
                    (dashboard.setup {:theme :doom
                                      :config {:header ["            "
                                                        "            "
                                                        "    ↑↑↓↓    "
                                                        "   ←→←→AB   "
                                                        "   ┌────┐   "
                                                        "   │    ├┐  "
                                                        "   │┌ ┌ └│  "
                                                        "   │ ╘  └┘  "
                                                        "   │    │   "
                                                        "   │╙─  │   "
                                                        "   │    │   "
                                                        "   └──┘ │   "
                                                        "     │  │   "
                                                        "     │  │   "
                                                        "            "
                                                        "            "
                                                        "            "]
                                               :footer custom-footer
                                               :packages {:enable false}
                                               :mru {:limit 5}
                                               :shortcut [{:desc "Last session"
                                                           :key :l
                                                           :group :DashboardMruTitle
                                                           :action "SessionManager load_current_dir_session"}
                                                          {:desc "Find file"
                                                           :key :p
                                                           :group :DashboardMruTitle
                                                           :action "Telescope find_files"}
                                                          {:desc "Find word"
                                                           :key :f
                                                           :group :DashboardMruTitle
                                                           :action "Telescope live_grep"}]
                                               :center [{:desc "Last Session"
                                                         :icon " "
                                                         :key :l
                                                         :action "SessionManager load_current_dir_session"}
                                                        {:desc "Find file"
                                                         :icon " "
                                                         :key :p
                                                         :action "Telescope find_files"}
                                                        {:desc "Open changed files"
                                                         :icon " "
                                                         :key :c
                                                         :action "call v:lua.EditChangedFiles()"}
                                                        {:desc "Find word"
                                                         :icon " "
                                                         :key :w
                                                         :action "Telescope live_grep"}]}})))})
 (pack :nocksock/do.nvim
       {:config true
        :opts {:doing_prefix "In progress: "
               :winbar false
               :store {:file_name :.todo :auto_create_file true}}})
 (pack :lewis6991/gitsigns.nvim {:dependencies [:nvim-lua/plenary.nvim]
                                 :config true})
 (pack :Yggdroot/indentLine
       {:config (fn []
                  (tset vim.g :indentLine_fileTypeExclude
                        [:dashboard :fennel :mason])
                  (tset vim.g :indentLine_concealcursor :n)
                  (tset vim.g :indentLine_char_list ["|" "¦" "┆" "┊"]))})
 (pack :nvim-lualine/lualine.nvim
       {:dependencies [:nvim-web-devicons
                       :nocksock/do.nvim
                       :glepnir/lspsaga.nvim
                       :natecraddock/workspaces.nvim
                       :ribru17/bamboo.nvim]
        :config (fn []
                  (let [lualine (require :lualine)]
                    (lualine.setup {:winbar {:lualine_c [(fn []
                                                           ((. (require :do)
                                                               :view) :active))]}
                                    :inactive_winbar {}
                                    :options {:component_separators {:left ""
                                                                     :right ""}
                                              :section_separators {:left ""
                                                                   :right ""}
                                              :theme (require :lualine_theme)
                                              :disabled_filetypes {:statusline [:lspsagaoutline
                                                                                :NvimTree]
                                                                   :winbar [:lspsagaoutline
                                                                            :NvimTree
                                                                            :dashboard]}}
                                    :sections {:lualine_a [:mode]
                                               :lualine_b [(fn []
                                                             (var output
                                                                  (vim.split (vim.api.nvim_exec :WorkspacesList
                                                                                                true)
                                                                             "\n"))
                                                             (set output
                                                                  (icollect [_ v (ipairs output)]
                                                                    (if (> (length v)
                                                                           0)
                                                                        v)))
                                                             (var fin "")
                                                             (each [_ v (ipairs output)]
                                                               (let [path (string.gsub (string.gsub v
                                                                                                    "[%a%A]* "
                                                                                                    "")
                                                                                       "/$"
                                                                                       "")]
                                                                 (if (string.find (vim.api.nvim_exec :pwd
                                                                                                     true)
                                                                                  path)
                                                                     (set fin
                                                                          (string.gsub v
                                                                                       " [%a%A]+"
                                                                                       "")))))
                                                             fin)
                                                           {1 :filename
                                                            :cond (fn []
                                                                    (local winbar
                                                                           (require :lspsaga.symbolwinbar))
                                                                    (= (winbar:get_winbar)
                                                                       nil))}]
                                               :lualine_c [(fn []
                                                             (local winbar
                                                                    (require :lspsaga.symbolwinbar))
                                                             (.. (winbar:get_winbar)
                                                                 "%#EndOfBuffer#"))]
                                               :lualine_x [:diagnostics]
                                               :lualine_y [:filetype]
                                               :lualine_z [[#""
                                                            :color
                                                            (fn []
                                                              {:fg (. (require :bamboo.colors)
                                                                      :blue)})]]}
                                    :inactive_sections {:lualine_a []
                                                        :lualine_b []
                                                        :lualine_c [:filename]
                                                        :lualine_x [:location]
                                                        :lualine_y []
                                                        :lualine_z []}
                                    :tabline []
                                    :extensions []})))})
 (pack :terrortylor/nvim-comment
       {:config (fn []
                  (let [nvim-comment (require :nvim_comment)]
                    (nvim-comment.setup {:line_mapping :<leader>cc
                                         :operator_mapping :<leader>c})))})
 (pack :kevinhwang91/nvim-ufo
       {:dependencies [:kevinhwang91/promise-async
                       (pack :luukvbaal/statuscol.nvim
                             {:config (fn []
                                        (let [statuscol (require :statuscol)
                                              builtin (require :statuscol.builtin)]
                                          (statuscol.setup {:foldfunc :builtin
                                                            :setopt true
                                                            :relculright true
                                                            :segments [{:text [builtin.foldfunc]
                                                                        :click "v:lua.ScFa"}
                                                                       {:text ["%s"]
                                                                        :click "v:lua.ScSa"}
                                                                       {:text [builtin.lnumfunc
                                                                               " "]
                                                                        :click "v:lua.ScLa"}]})))})]
        :init (fn []
                (set vim.o.foldcolumn :1)
                (set vim.o.foldlevel 99)
                (set vim.o.foldenable true)
                (set vim.o.fillchars
                     "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"))
        :config true
        :opts {:provider_selector (fn []
                                    [:treesitter :indent])}})
 (pack :folke/todo-comments.nvim {:dependencies [:nvim-lua/plenary.nvim]
                                  :config true
                                  :opts {:keywords {:FIX {:color :warning}}
                                         :WARN {:alt :EDIT}
                                         ; implement custom highlight/search regexp if necessary
                                         ; :highlight {:pattern ".*(KEYWORDS)*" :keyword :bg}
                                         ; :search {:pattern ".*<(KEYWORDS).*/>"}
                                         }})
 (pack :folke/which-key.nvim {:config true :opts {:window {:border :rounded}}})
 (pack :Shatur/neovim-session-manager
       {:config (fn []
                  (let [session-manager (require :session_manager)
                        config (require :session_manager.config)]
                    (session-manager.setup {:autoload_mode config.AutoloadMode.Disabled
                                            :max_path_length 0})))})
 (pack :natecraddock/workspaces.nvim
       {:dependencies [:Shatur/neovim-session-manager
                       :nvim-telescope/telescope.nvim]
        :config (fn []
                  (let [workspaces (require :workspaces)]
                    (workspaces.setup {:hooks {:open_pre (fn []
                                                           (let [session-manager (require :session_manager)]
                                                             (session-manager.save_current_session)))
                                               :open (fn []
                                                       (let [session-manager (require :session_manager)]
                                                         (session-manager.load_current_dir_session)))}})
                    ((. (require :telescope) :load_extension) :workspaces)))})
 (pack :folke/zen-mode.nvim
       {:config true
        :opts {:window {:backdrop 1
                        :height 0.73
                        :options {:number false :relativenumber false}}}})
 :rhysd/committia.vim
 :wincent/loupe
 :sbdchd/neoformat
 :dstein64/vim-startuptime]
