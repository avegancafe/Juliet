(var plugins [{1 :rktjmp/hotpot.nvim :dependencies [:datwaft/themis.nvim]}])
(local fnl-definition-paths (.. (vim.fn.stdpath :config) :/fnl/plugins))

(if (vim.loop.fs_stat fnl-definition-paths)
  (each [file (vim.fs.dir fnl-definition-paths)]
    (when (not= file :index.fnl)
      (table.insert plugins (require (.. :plugins. (file:match "^(.*)%.fnl$")))))))

((. (require :lazy) :setup) plugins {:ui {:border :rounded}})
