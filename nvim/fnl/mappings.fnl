(local {: merge} (require :utils))
(fn create-map-func [mode]
  (fn [binding command opts]
    (vim.api.nvim_set_keymap mode binding command
                             (merge {:noremap true} (or opts {})))))

(local normal-map (create-map-func :n))

(normal-map :<leader>p ":Lazy<cr>" {:silent true})
(normal-map :<leader>ev ":tabe ~/.config/Juliet/nvim/init.lua<cr>")
(normal-map :<leader>sv ":source $MYVIMRC<cr>")
(normal-map :<leader>it ":put =strftime('%FT%T%z')<cr>")
(normal-map :<leader>id "a<C-R>=strftime(\"%Y-%m-%d\")<cr><esc>")
(normal-map :H "^")
(normal-map :L :g$)
(normal-map "q:" :<nop>)
(normal-map :<leader>dd ":TroubleToggle document_diagnostics<cr>")
(normal-map :<leader>d ":TroubleToggle<cr>")
(normal-map :<leader>d5 ":TroubleRefresh<cr>")
(normal-map :<leader>h ":Dashboard<cr>")
(normal-map :gQ
            ":echo \"Ex mode disabled. Re-enable in your mappigns if you'd like to use it.\"<cr>")

(vim.keymap.set :n :zR (. (require :ufo) :openAllFolds))
(vim.keymap.set :n :zM (. (require :ufo) :closeAllFolds))
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
(normal-map :<c-p> ":Telescope find_files<cr>" {:silent true})
(normal-map :<c-b> ":Telescope buffers<cr>" {:silent true})
(normal-map :<c-o> ":w<cr>" {:silent true})
(tset _G :GitlabOpen (fn []
                       (let [filepath (vim.trim (vim.fn.fnamemodify (vim.fn.expand "%")
                                                                    ":~:."))
                             command (.. "fish -c 'glo -c " filepath "'")]
                         (os.capture command)
                         (vim.cmd :mode))))

(normal-map :<leader>cp ":let @*=expand(\"%:p\")<cr>" {:silent true})
(normal-map :<c-f> ":ZenMode<cr>" {:silent true})
(normal-map :<leader>f ":NvimTreeToggle<CR>" {:silent true})
(normal-map :<leader>fr ":NvimTreeRefresh<CR>" {:silent true})
(normal-map :<leader>ff ":NvimTreeFindFile<CR>" {:silent true})
(normal-map :<leader>fb ":Telescope file_browser<CR>" {:silent true})
(normal-map :<leader>x ":noh<cr>" {:silent true})
(normal-map :<tab> ":BufferLineCycleNext<cr>" {:silent true})
(normal-map :<s-tab> ":BufferLineCyclePrev<cr>" {:silent true})
(normal-map :<leader>ss ":SessionManager save_current_session<cr>")
(normal-map :<leader>sl ":Telescope workspaces<cr>" {:silent true})
(normal-map :<leader>sc ":call v:lua.EditChangedFiles()<cr>")
(normal-map :<leader>b ":BufferLinePick<cr>" {:silent true})
(normal-map :<leader>bb ":BufferLinePick<cr>" {:silent true})
(normal-map :<leader>bc ":BufferLinePickClose<cr>" {:silent true})
(normal-map :<leader>bg ":BufferLineGroupToggle " {:silent true})
(normal-map :<leader>bf ":Neoformat<cr>" {:silent true})
(normal-map :<leader>bo ":call v:lua.GitlabOpen()<cr>" {:silent true})
(normal-map :<leader>t ":Lspsaga term_toggle<cr>" {:silent true})
(normal-map :<leader>bt ":lua require(\"cmds/switch_bufferline_mode\")()<cr>"
            {:silent true})

(normal-map :<leader>rs ":let @a=@*<cr>" {:silent true})
(normal-map :<leader>rsa ":let @a=@*<cr>" {:silent true})
(normal-map :<leader>rsb ":let @b=@*<cr>" {:silent true})
(normal-map :<leader>rsc ":let @c=@*<cr>" {:silent true})
(normal-map :<leader>rsd ":let @d=@*<cr>" {:silent true})
(normal-map :<leader>dc ":lua require\"dap\".continue()<cr>" {:silent true})
(normal-map :<leader>ds ":lua require\"dap\".step_over()<cr>" {:silent true})
(normal-map :<leader>dso ":lua require\"dap\".step_over()<cr>" {:silent true})
(normal-map :<leader>dsi ":lua require\"dap\".step_into()<cr>" {:silent true})
(normal-map :<leader>dsu ":lua require\"dap\".step_out()<cr>" {:silent true})
(normal-map :<leader>db ":lua require\"dap\".toggle_breakpoint()<cr>"
            {:silent true})

(normal-map :<leader>dr ":lua require\"dap\".repl.open()<cr>" {:silent true})
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
