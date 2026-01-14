(import-macros {: pack} :Juliet.macros)
(pack :nvim-telescope/telescope-fzf-native.nvim
      {:dependencies [:nvim-telescope/telescope.nvim]
       :build "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install"}
      :init (fn []
             (let [telescope (require :telescope)]
               (telescope.load_extension :fzf))))
