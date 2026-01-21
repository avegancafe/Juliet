(import-macros {: pack} :Juliet.macros)

(pack :wakatime/vim-wakatime
      {:lazy false
       :cond #(os.getenv :WAKATIME_API_KEY)})
