(import-macros {: pack} :Juliet.macros)

(pack :ribru17/bamboo.nvim
      {:config (fn []
                 (let [bamboo (require :bamboo)]
                   (bamboo.setup {})
                   (bamboo.load)))
       :init (fn []
               (let [colors (require :bamboo.colors)]
                 (vim.api.nvim_set_hl 0 :WhichKeyNormal {:bg colors.bg1})
                 (vim.api.nvim_set_hl 0 :WhichKeyBorder {:bg colors.bg1})
                 (vim.api.nvim_set_hl 0 :WhichKeyTitle {:bg colors.bg1})
                 (vim.api.nvim_set_hl 0 :FloatBorder {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :TelescopeResultsBorder
                                      {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :TelescopePromptBorder
                                      {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :TelescopePreviewBorder
                                      {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :MiniPickBorder {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :MiniPickPrompt {:fg colors.fg})
                 (vim.api.nvim_set_hl 0 :TabLineSep {:bg colors.green})
                 (vim.api.nvim_set_hl 0 :TabLine
                                      {:bg colors.white :fg colors.white})
                 (vim.api.nvim_set_hl 0 :TabLineSel {:bg colors.bg0})
                 (vim.api.nvim_set_hl 0 :TabLine {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :LineNr {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :CursorLineNr {:fg colors.green})
                 (vim.api.nvim_set_hl 0 :Folded {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :BlinkCmpSignatureHelpBorder
                                      {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :PmenuExtra {:fg colors.grey})
                 (vim.api.nvim_set_hl 0 :TabLineFill
                                      {:fg colors.black :bg colors.black})))})
