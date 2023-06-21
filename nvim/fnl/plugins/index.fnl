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

(var plugins [[:rktjmp/hotpot.nvim]])
(local fnl-definition-paths (.. (vim.fn.stdpath :config) :/fnl/plugins))

(if (vim.loop.fs_stat fnl-definition-paths)
    (each [file (vim.fs.dir fnl-definition-paths { :depth 3 })]
      (when (and (not= file :index.fnl) (file:match "^(.*)%.fnl$"))
        (table.insert plugins
                      (require (.. :plugins. (file:match "^(.*)%.fnl$")))))))

((. (require :lazy) :setup) plugins {:ui {:border :rounded}})
