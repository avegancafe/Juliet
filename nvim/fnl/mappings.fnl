(local {: merge} (require :utils))
(fn create-map-func [mode]
  (fn [binding command opts]
    (vim.api.nvim_set_keymap mode binding command
                             (merge {:noremap true} (or opts {})))))

(local normal-map (create-map-func :n))

(normal-map :<leader>p ":Lazy<cr>" {:silent true :desc "Open lazy.nvim"})
(normal-map :<leader>it ":put =strftime('%FT%T%z')<cr>"
            {:desc "Insert timestamp below this line"})

(normal-map :<leader>id "a<C-R>=strftime(\"%Y-%m-%d\")<cr><esc>"
            {:desc "Insert current date at cursor"})

(normal-map :H "^")
(normal-map :L :g$)
(normal-map "q:" :<nop>)
(normal-map :gQ
            ":echo \"Ex mode disabled. Re-enable in your mappigns if you'd like to use it.\"<cr>")

(tset _G :ToggleNumbers
      (fn []
        (if (= vim.opt.relativenumber._value true)
            (tset vim.opt :relativenumber false)
            (tset vim.opt :relativenumber true))))

(vim.cmd ":command ToggleNumbers call v:lua.ToggleNumbers()")
(vim.cmd ":command Todo execute \"TodoTrouble cwd=\".getreg('%')")
(vim.cmd ":abbreviate bgt BufferLineGroupToggle")
(tset _G :ShowEditsInCurrentDir
      (fn []
        (let [cwd (vim.fn.fnamemodify (vim.fn.expand "%:h") ":~:.")]
          (vim.cmd (.. "TodoTrouble keywords=EDIT cwd=" cwd)))))

(vim.cmd ":command ShowEditsInCurrentDir call v:lua.ShowEditsInCurrentDir()")
(normal-map :<c-o> ":w<cr>" {:silent true})
(tset _G :GitlabOpen (fn []
                       (let [filepath (vim.trim (vim.fn.fnamemodify (vim.fn.expand "%")
                                                                    ":~:."))
                             command (.. "fish -c 'glo -c " filepath "'")]
                         (os.capture command)
                         (vim.cmd :mode))))

(normal-map :<leader>cp ":let @*=expand(\"%:p\")<cr>" {:silent true})
(normal-map :<leader>x ":noh<cr>" {:silent true})
(normal-map :<leader>sc ":call v:lua.EditChangedFiles()<cr>"
            {:desc "Edit all changed files"})
(normal-map :<leader>bo ":call v:lua.GitlabOpen()<cr>"
            {:silent true :desc "Open file in gitlab"})

(normal-map :<leader>bt ":lua require(\"cmds/switch_bufferline_mode\")()<cr>"
            {:silent true :desc "Toggle between buffer mode and tab mode"})

(normal-map :<leader>rs ":let @a=@*<cr>"
            {:silent true :desc "Save register to @a"})

(normal-map :<leader>rsa ":let @a=@*<cr>"
            {:silent true :desc "Save register to @a"})

(normal-map :<leader>rsb ":let @b=@*<cr>"
            {:silent true :desc "Save register to @b"})

(normal-map :<leader>rsc ":let @c=@*<cr>"
            {:silent true :desc "Save register to @c"})

(normal-map :<leader>rsd ":let @d=@*<cr>"
            {:silent true :desc "Save register to @d"})

(tset _G :EditChangedFiles
      (fn []
        (let [files-output (vim.api.nvim_exec :!changed_files true)
              changed-files (. (vim.split files-output "\n") 3)]
          (vim.cmd (.. "args " changed-files)))))

(vim.cmd ":command EditChangedFiles call v:lua.EditChangedFiles()")

(local terminal-map (create-map-func :t))
(terminal-map "<c-[>" "<c-\\><c-n>")
(vim.cmd ":abbreviate ag Telescope live_grep")
(local insert-map (create-map-func :i))
(insert-map :<c-c> :<esc>)
(insert-map :<d-v> :<c-r>* {:silent true})
