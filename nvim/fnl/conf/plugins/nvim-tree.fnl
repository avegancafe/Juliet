(import-macros {: pack} :themis.pack.lazy)

(pack :kyazdani42/nvim-tree.lua
      {:dependencies :kyazdani42/nvim-web-devicons
       :config true
       :opts {:view {:float {:enable true
                             :open_win_config {:relative :editor
                                               :anchor :NE
                                               :row (- (vim.api.nvim_buf_line_count 0)
                                                       1)
                                               :col (- vim.go.columns 1)}}}}})
