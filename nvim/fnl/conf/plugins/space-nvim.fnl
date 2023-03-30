(import-macros {: pack} :themis.pack.lazy)

(pack :Th3Whit3Wolf/space-nvim
      {:config (fn []
                 (let [void (require :void)
                       space-nvim (require :space-nvim)]
                   (space-nvim void.highlight_group_normal
                               void.highlight_groups void.terminal_ansi_colors)
                   (vim.cmd "colorscheme void")))})
