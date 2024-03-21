(import-macros {: pack} :Juliet.macros)

(pack :nvim-lualine/lualine.nvim
      {:dependencies [:nvim-web-devicons
                      :nocksock/do.nvim
                      :natecraddock/workspaces.nvim
                      :ribru17/bamboo.nvim
                      :nvim-lua/plenary.nvim]
       :config (fn []
                 (set vim.o.laststatus 3)
                 (let [lualine (require :lualine)
                       cache-fn (fn [f]
                                  (var last-call nil)
                                  (var last-result nil)
                                  (fn []
                                    (if (= last-call nil) (f)
                                        (if (> (- last-call (os.time)) 60)
                                            (do
                                              (set last-result (f))
                                              (set last-call (os.time))
                                              last-result)))))]
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
                                              :lualine_c [(fn []
                                                            (local Path
                                                                   (require :plenary.path))
                                                            (local p
                                                                   (string.gsub (vim.api.nvim_buf_get_name 0)
                                                                                (vim.loop.cwd)
                                                                                ""))
                                                            (.. (: (Path:new p)
                                                                   :shorten 3
                                                                   [-1 -2])
                                                                "%#EndOfBuffer#"))]
                                              :lualine_x [(fn []
                                                            (local configpulse
                                                                   (require :configpulse))
                                                            (local get-time (cache-fn configpulse.get_time))
                                                            (local time
                                                                   (get-time))
                                                            (.. "It's been "
                                                                time.days
                                                                " days "
                                                                time.hours ":"
                                                                (string.format "%02d"
                                                                               time.minutes)))
                                                          :branch
                                                          :diagnostics]
                                              :lualine_y [:filetype]
                                              :lualine_z []}
                                   :inactive_sections {:lualine_a []
                                                       :lualine_b []
                                                       :lualine_c [:filename]
                                                       :lualine_x [:location]
                                                       :lualine_y []
                                                       :lualine_z []}
                                   :tabline []
                                   :extensions []})))})
