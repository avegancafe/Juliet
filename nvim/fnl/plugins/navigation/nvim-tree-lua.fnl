(import-macros {: pack : key} :macros)

(pack :kyazdani42/nvim-tree.lua
      {:keys [(key :<leader>f ":NvimTreeToggle<cr>" "Toggle nvim-tree")
              (key :<leader>fr ":NvimTreeRefresh<CR>" "Refresh nvim-tree")
              (key :<leader>ff ":NvimTreeFindFile<CR>" "Find file in nvim-tree")]
       :dependencies :kyazdani42/nvim-web-devicons
       :config true
       :opts {:view {:float {:enable true
                             :open_win_config {:relative :editor
                                               :anchor :NE
                                               :row (- (vim.api.nvim_buf_line_count 0)
                                                       1)
                                               :col (- vim.go.columns 1)}}}}})
