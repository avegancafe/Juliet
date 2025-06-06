(import-macros {: pack : key} :Juliet.macros)

(fn show-edits-in-current-dir []
  (let [cwd (vim.fn.fnamemodify (vim.fn.expand "%:h") ":~:.")]
    (vim.cmd (.. "TodoTrouble keywords=EDIT cwd=" cwd))))

(pack :folke/todo-comments.nvim
      {:dependencies [:nvim-lua/plenary.nvim]
       :config true
       :lazy false
       :keys [(key :<leader>bt :<cmd>TodoTrouble<cr> "List Todos in pwd")]
       :opts {}
       :init (fn []
               (vim.api.nvim_create_user_command :Todo
                                                 (fn []
                                                   (let [cwd (vim.fn.fnamemodify (vim.fn.expand "%:h")
                                                                                 ":~:.")]
                                                     (vim.cmd (.. "TodoTrouble cwd='"
                                                                  cwd "'"))))
                                                 {})
               (vim.api.nvim_create_user_command :ShowEditsInCurrentDir
                                                 show-edits-in-current-dir {}))})
