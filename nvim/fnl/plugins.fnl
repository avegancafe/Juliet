(local plugins [{1 :rktjmp/hotpot.nvim :dependencies [:datwaft/themis.nvim]}])
(local fnl-definition-paths (.. (vim.fn.stdpath :config) :/fnl/conf/plugins))

(when (vim.loop.fs_stat fnl-definition-paths)
  (each [file (vim.fs.dir fnl-definition-paths)]
    (tset plugins (+ (length plugins) 1)
          (require (.. :conf.plugins. (file:match "^(.*)%.fnl$"))))))

((. (require :lazy) :setup) plugins {:ui {:border :rounded}})
