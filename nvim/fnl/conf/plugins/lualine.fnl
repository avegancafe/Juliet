(import-macros {: pack} :themis.pack.lazy)

(pack :nvim-lualine/lualine.nvim
      {:dependencies [:nvim-web-devicons
                      :nocksock/do.nvim
                      :glepnir/lspsaga.nvim
                      :natecraddock/workspaces.nvim]
       :config true
       :opts {:winbar {:lualine_c [(fn []
                                     ((. (require :do) :view) :active))]}
              :inactive_winbar {:lualine_c [(fn []
                                              ((. (require :do) :view) :inactivev))]}
              :options {:component_separators {:left "" :right ""}
                        :section_separators {:left "" :right ""}
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
                                              (if (> (length v) 0) v)))
                                       (var fin "")
                                       (each [_ v (ipairs output)]
                                         (let [path (string.gsub (string.gsub v
                                                                              "[%a%A]* "
                                                                              "")
                                                                 "/$" "")]
                                           (if (= path
                                                  (vim.api.nvim_exec :pwd true))
                                               (set fin
                                                    (string.gsub v " [%a%A]+"
                                                                 "")))))
                                       fin)
                                     [:filename
                                      :cond
                                      (fn []
                                        (= ((. (require :lspsaga.symbolwinbar)
                                               :get_winbar))
                                           nil))]]
                         :lualine_c [(fn []
                                       (.. ((. (require :lspsaga.symbolwinbar)
                                               :get_winbar))
                                           "%#EndOfBuffer#"))
                                     :diagnostics]
                         :lualine_x []
                         :lualine_y [:filetype]
                         :lualine_z [[#"|"
                                      :color
                                      {:fg (. (require :void_colors) :bg)}]
                                     [#""
                                      :color
                                      {:fg (. (require :void_colors) :red)}]]}
              :inactive_sections {:lualine_a []
                                  :lualine_b []
                                  :lualine_c [:filename]
                                  :lualine_x [:location]
                                  :lualine_y []
                                  :lualine_z []}
              :tabline []
              :extensions []}})
