(import-macros {: pack} :Juliet.macros)

(local lazy-plugins-path (.. (vim.fn.stdpath :data) :/lazy))
(local lazy-path (.. lazy-plugins-path :/lazy.nvim))

(when (not (vim.loop.fs_stat lazy-path))
  (vim.fn.system [:git
                  :clone
                  "--filter=blob:none"
                  "https://github.com/folke/lazy.nvim.git"
                  :--branch=stable
                  lazy-path]))

(vim.opt.rtp:prepend lazy-path)

(var plugins [(pack :rktjmp/hotpot.nvim {:version "^2.0.0"})])
(local fnl-definition-paths (.. (vim.fn.stdpath :config) :/fnl/Juliet/plugins))

(if (vim.loop.fs_stat fnl-definition-paths)
    (each [file (vim.fs.dir fnl-definition-paths { :depth 3 })]
      (when (and (not= file :init.fnl) (file:match "^(.*)%.fnl$"))
        (table.insert plugins
                      (require (.. :Juliet.plugins. (file:match "^(.*)%.fnl$")))))))

(local hotpot-context
       (let [api (require :hotpot.api)]
         (assert (api.context (vim.fn.stdpath :config)))))

((. (require :lazy) :setup) plugins
 {:ui {:border :rounded}
  :performance {:rtp {:paths [(hotpot-context.locate :destination)]}}})
