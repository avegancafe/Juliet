(import-macros {: pack} :themis.pack.lazy)

(pack :glepnir/lspsaga.nvim
      {:event :BufRead
       :dependencies [:kyazdani42/nvim-web-devicons
                      :nvim-treesitter/nvim-treesitter]
       :config (fn []
                 (let [lspsaga (require :lspsaga)]
                   (lspsaga.setup {:outline {:win_width 40
                                             :keys {:jump :<cr>
                                                    :expand_collapse :u}}
                                   :ui {:border :rounded}
                                   :symbol_in_winbar {:enable false
                                                      :separator "  "
                                                      :hide_keyword false
                                                      :show_file true
                                                      :respect_root true
                                                      :color_mode true}})))})
