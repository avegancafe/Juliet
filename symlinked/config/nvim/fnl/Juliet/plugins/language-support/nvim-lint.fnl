(import-macros {: pack} :Juliet.macros)

(pack :mfussenegger/nvim-lint {:config (fn []
                                         (let [lint (require :lint)
                                               golangcilint (require :lint.linters.golangcilint)]
                                           (set lint.linters_by_ft
                                                 {:go [:golangcilint]
                                                  :javascript [:eslint]
                                                  :typescript [:eslint]
                                                  :typescriptreact [:eslint]
                                                  :python [:ruff]})
                                           (set golangcilint.append_fname
                                                 true)
                                           (set golangcilint.args
                                                 [:run
                                                  :--out-format
                                                  :json
                                                  :--config
                                                  "~/workspace/api-v2-backend/.build/scripts/.golangci.yml"])
                                           (vim.api.nvim_create_autocmd [:BufWrite
                                                                         :BufRead]
                                                                        {:callback (fn []
                                                                                     (let [lint (require :lint)]
                                                                                       (lint.try_lint nil
                                                                                                      {:ignore_errors true})))})
                                           nil))})

