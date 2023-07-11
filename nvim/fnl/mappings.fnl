(vim.keymap.set :n :<leader>p ":Lazy<cr>" {:silent true :desc "Open lazy.nvim"})
(vim.keymap.set :n :<leader>it ":put =strftime('%FT%T%z')<cr>"
                {:desc "Insert timestamp below this line"})

(vim.keymap.set :n :<leader>id "a<C-R>=strftime(\"%Y-%m-%d\")<cr><esc>"
                {:desc "Insert current date at cursor"})

(vim.keymap.set :n :H "^")
(vim.keymap.set :n :L :g$)
(vim.keymap.set :n "q:" :<nop>)
(vim.keymap.set :x :p "p<cmd>let @+=@0<CR><cmd>let @\"=@0<CR>"
                {:noremap true :silent true})

(vim.keymap.set :n :<c-u> :<c-u>zz {:silent true})
(vim.keymap.set :n :<c-d> :<c-d>zz {:silent true})
(vim.api.nvim_set_keymap :x ">" :>gv {:noremap true})
(vim.api.nvim_set_keymap :x "<" :<gv {:noremap true})
(vim.keymap.set :n :gQ
                ":echo \"Ex mode disabled. Re-enable in your mappigns if you'd like to use it.\"<cr>")

(vim.api.nvim_set_keymap :n :gf :gF {:noremap true})
(vim.api.nvim_set_keymap :x :gf :gF {:noremap true})

(vim.api.nvim_set_keymap :n :gF ":e <cfile><CR>" {:noremap true})
(vim.api.nvim_set_keymap :x :gF ":e <cfile><CR>" {:noremap true})

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
(vim.keymap.set :n :<c-o> ":w<cr>" {:silent true})
(tset _G :GitlabOpen (fn []
                       (let [filepath (vim.trim (vim.fn.fnamemodify (vim.fn.expand "%")
                                                                    ":~:."))
                             command (.. "fish -c 'glo -c " filepath "'")]
                         (os.capture command)
                         (vim.cmd :mode))))

(vim.keymap.set :n :<leader>cp ":let @*=expand(\"%:p\")<cr>" {:silent true})
(vim.keymap.set :n :<leader>x ":noh<cr>" {:silent true})
(vim.keymap.set :n :<leader>sc ":call v:lua.EditChangedFiles()<cr>"
                {:desc "Edit all changed files"})

(vim.keymap.set :n :<leader>bo ":call v:lua.GitlabOpen()<cr>"
                {:silent true :desc "Open file in gitlab"})

(vim.keymap.set :n :<leader>bt
                ":lua require(\"cmds/switch_bufferline_mode\")()<cr>"
                {:silent true :desc "Toggle between buffer mode and tab mode"})

(vim.keymap.set :n :<leader>rs ":let @a=@*<cr>"
                {:silent true :desc "Save register to @a"})

(vim.keymap.set :n :<leader>rsa ":let @a=@*<cr>"
                {:silent true :desc "Save register to @a"})

(vim.keymap.set :n :<leader>rsb ":let @b=@*<cr>"
                {:silent true :desc "Save register to @b"})

(vim.keymap.set :n :<leader>rsc ":let @c=@*<cr>"
                {:silent true :desc "Save register to @c"})

(vim.keymap.set :n :<leader>rsd ":let @d=@*<cr>"
                {:silent true :desc "Save register to @d"})

(tset _G :EditChangedFiles
      (fn []
        (let [files-output (vim.api.nvim_exec :!changed_files true)
              changed-files (. (vim.split files-output "\n") 3)]
          (vim.cmd (.. "args " changed-files)))))

(vim.cmd ":command EditChangedFiles call v:lua.EditChangedFiles()")

(vim.keymap.set :t "<c-[>" "<c-\\><c-n>")
(vim.cmd ":abbreviate ag Telescope live_grep")
(vim.keymap.set :i :<c-c> :<esc>)
(vim.keymap.set :i :<d-v> :<c-r>* {:silent true})
