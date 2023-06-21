(import-macros {: pack} :macros)

(pack :glepnir/lspsaga.nvim {:event :LspAttach
                             :dependencies [:kyazdani42/nvim-web-devicons
                                            :nvim-treesitter/nvim-treesitter]
                             :init (fn []
                                     (vim.fn.sign_define :DiagnosticSignError
                                                         {:texthl :DiagnosticSignError
                                                          :text ""
                                                          :numhl :DiagnosticSignError})
                                     (vim.fn.sign_define :DiagnosticSignWarn
                                                         {:texthl :DiagnosticSignWarn
                                                          :text ""
                                                          :numhl :DiagnosticSignWarn})
                                     (vim.fn.sign_define :DiagnosticSignHint
                                                         {:texthl :DiagnosticSignHint
                                                          :text ""
                                                          :numhl :DiagnosticSignHint})
                                     (vim.fn.sign_define :DiagnosticSignInfo
                                                         {:texthl :DiagnosticSignInfo
                                                          :text ""
                                                          :numhl :DiagnosticSignInfo}))
                             :opts {:outline {:win_width 40
                                              :keys {:jump :<cr>
                                                     :expand_collapse :u}}
                                    :ui {:border :rounded}
                                    :symbol_in_winbar {:enable false
                                                       :separator "  "
                                                       :hide_keyword false
                                                       :show_file true
                                                       :respect_root true
                                                       :color_mode true}}
                             :config true})
