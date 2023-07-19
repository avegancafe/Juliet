(import-macros {: pack : key} :Juliet.macros)
(local setup-bufferline (require :Juliet.cmds.setup_bufferline))

(pack :akinsho/bufferline.nvim
      {:lazy false
       :keys [(key :<tab> ":BufferLineCycleNext<cr>" "Next tab")
              (key :<s-tab> ":BufferLineCyclePrev<cr>" "Previous tab")
              (key :<leader>b ":BufferLinePick<cr>" "Pick specific tab")
              (key :<leader>bb ":BufferLinePick<cr>" "Pick specific tab")
              (key :<leader>bc ":BufferLinePickClose<cr>" "Close specific tab")]
       :dependencies [:ribru17/bamboo.nvim]
       :config (fn []
                 (setup-bufferline.setup :buffers))})
