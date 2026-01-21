(import-macros {: pack} :Juliet.macros)

(fn wakatime-configured? []
  (let [path (.. (os.getenv :HOME) :/.wakatime.cfg)
        file (io.open path :r)]
    (when file
      (let [content (file:read :*a)]
        (file:close)
        (content:match "api_key%s*=%s*(%S+)")))))

(pack :wakatime/vim-wakatime {:lazy false :cond wakatime-configured?})
