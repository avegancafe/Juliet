(import-macros {: pack} :Juliet.macros)

(pack :nocksock/do.nvim
      {:config true
       :opts {:doing_prefix "In progress: "
              :winbar false
              :store {:file_name :.todo :auto_create_file true}}})
