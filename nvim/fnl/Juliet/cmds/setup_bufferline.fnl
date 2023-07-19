(local M {})
(fn M.setup [buf-mode]
  (let [colors (require :bamboo.colors)]
    ((. (require :bufferline) :setup) {:highlights {:buffer_selected {:bold false
                                                                      :italic false
                                                                      :underline false}
                                                    :diagnostic_selected {:bold false
                                                                          :underline false}
                                                    :error_diagnostic_selected {:bold false
                                                                                :underline false}
                                                    :error_selected {:bold false
                                                                     :underline false}
                                                    :hint_diagnostic_selected {:bold false
                                                                               :underline false}
                                                    :hint_selected {:bold false
                                                                    :underline false}
                                                    :indicator_selected {:fg colors.green}
                                                    :info_diagnostic_selected {:bold false
                                                                               :underline false}
                                                    :info_selected {:bold false
                                                                    :underline false}
                                                    :numbers_selected {:bold false
                                                                       :underline false}
                                                    :pick {:bold false}
                                                    :pick_selected {:bold false
                                                                    :underline false}
                                                    :pick_visible {:bold false}
                                                    :separator {:fg colors.bg1}
                                                    :warning_diagnostic_selected {:bold false
                                                                                  :underline false}
                                                    :warning_selected {:bold false
                                                                       :underline false}}
                                       :options {:mode buf-mode
                                                 :offsets [{:filetype :NvimTree
                                                            :highlight :Directory
                                                            :text "File Explorer"
                                                            :text_align :left}]
                                                 :show_buffer_icons false}})))

M
