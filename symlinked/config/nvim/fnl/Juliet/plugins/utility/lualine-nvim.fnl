(import-macros {: pack} :Juliet.macros)

(pack :nvim-lualine/lualine.nvim
      {:dependencies [:nvim-tree/nvim-web-devicons
                      :nocksock/do.nvim
                      :natecraddock/workspaces.nvim
                      :ribru17/bamboo.nvim
                      :nvim-lua/plenary.nvim
                      :avegancafe/completionist.nvim
                      :SmiteshP/nvim-navic]
       :config (fn []
                 (set vim.o.laststatus 3)
                 (let [lualine (require :lualine)
                       configpulse (require :configpulse)
                       completionist (require :completionist)
                       time (configpulse.get_time)]
                   (lualine.setup {:winbar {:lualine_c [(fn []
                                                          ((. (require :do)
                                                              :view) :active))]}
                                   :inactive_winbar {}
                                   :options {:component_separators {:left ""
                                                                    :right ""}
                                             :section_separators {:left ""
                                                                  :right ""}
                                             :theme (require :Juliet.lualine_theme)
                                             :disabled_filetypes {:statusline [:NvimTree]
                                                                  :winbar [:NvimTree
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
                                                                                 path
                                                                                 1
                                                                                 true)
                                                                    (set fin
                                                                         (string.gsub v
                                                                                      " [%a%A]+"
                                                                                      "")))))
                                                            fin)]
                                              :lualine_c [{1 (fn []
                                                               (completionist.current_task))
                                                           :cond (fn []
                                                                   (not (= (completionist.current_task)
                                                                           "")))}]
                                              :lualine_x [(fn []
                                                            (let [navic (require :nvim-navic)]
                                                              (navic.get_location)))]
                                              :lualine_y [(fn []
                                                            (local Path
                                                                   (require :plenary.path))
                                                            (var p
                                                                 (Path:new (vim.api.nvim_buf_get_name 0)))
                                                            (p:make_relative))
                                                          (fn []
                                                            (if (not (= (vim.api.nvim_buf_get_name 0)
                                                                        ""))
                                                                "|"
                                                                ""))
                                                          (if (= (vim.fn.exists "g:neovide")
                                                                 0)
                                                              (fn []
                                                                (.. "It's been "
                                                                    time.days
                                                                    " days "
                                                                    time.hours
                                                                    ":"
                                                                    (string.format "%02d"
                                                                                   time.minutes)))
                                                              (fn [] ""))]
                                              :lualine_z [:diagnostics
                                                          :filetype]}
                                   :inactive_sections {:lualine_a []
                                                       :lualine_b []
                                                       :lualine_c [:filename]
                                                       :lualine_x [:location]
                                                       :lualine_y []
                                                       :lualine_z []}
                                   :tabline []
                                   :extensions []})))})
