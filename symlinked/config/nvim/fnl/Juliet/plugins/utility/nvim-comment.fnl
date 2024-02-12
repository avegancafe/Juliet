(import-macros {: pack} :Juliet.macros)

(pack :terrortylor/nvim-comment
      {:config (fn []
                 (let [nvim-comment (require :nvim_comment)]
                   (nvim-comment.setup {:line_mapping :<leader>cc
                                        :operator_mapping :<leader>c})))})
