(vim.keymap.set :n :<leader>it ":put =strftime('%FT%T%z')<cr>"
                {:desc "Insert timestamp below this line"})

(vim.keymap.set :n :<leader>id "a<C-R>=strftime(\"%Y-%m-%d\")<cr><esc>"
                {:desc "Insert current date at cursor"})

(vim.keymap.set :n :H "^")
(vim.keymap.set :n :L :g$)
(vim.keymap.set :n "q:" :<nop>)
(vim.keymap.set :x :p "p<cmd>let @+=@0<CR><cmd>let @\"=@0<CR>"
                {:noremap true :silent true})

(vim.keymap.set :n "<c-]>" "<c-]>zt" {:silent true})
(vim.keymap.set :n :<c-u> :<c-u>zz {:silent true})
(vim.keymap.set :n :<c-d> :<c-d>zz {:silent true})
(vim.keymap.set :n :<c-h> :<c-w>h {:silent true})
(vim.keymap.set :n :<c-j> :<c-w>j {:silent true})
(vim.keymap.set :n :<c-k> :<c-w>k {:silent true})
(vim.keymap.set :n :<c-l> :<c-w>l {:silent true})
(vim.keymap.set :x ">" :>gv {:noremap true})
(vim.keymap.set :x "<" :<gv {:noremap true})
(vim.keymap.set :n :gQ
                ":echo \"Ex mode disabled. Re-enable in your mappigns if you'd like to use it.\"<cr>")

(vim.keymap.set :n :gf :gF {:noremap true})
(vim.keymap.set :x :gf :gF {:noremap true})

(vim.keymap.set :n :gF ":e <cfile><CR>" {:noremap true})
(vim.keymap.set :x :gF ":e <cfile><CR>" {:noremap true})

(tset _G :ToggleNumbers
      (fn []
        (if (= vim.opt.relativenumber._value true)
            (do
              (tset vim.opt :relativenumber false)
              (vim.cmd ":tabdo windo set norelativenumber"))
            (do
              (tset vim.opt :relativenumber true)
              (vim.cmd ":tabdo windo set relativenumber")))))

(vim.cmd ":command! -bar ToggleNumbers call v:lua.ToggleNumbers()")
(vim.cmd ":command! Todo execute \"TodoTrouble cwd=\".getreg('%')")
(vim.cmd ":abbreviate bgt BufferLineGroupToggle")
(tset _G :ShowEditsInCurrentDir
      (fn []
        (let [cwd (vim.fn.fnamemodify (vim.fn.expand "%:h") ":~:.")]
          (vim.cmd (.. "TodoTrouble keywords=EDIT cwd=" cwd)))))

(vim.cmd ":command! ShowEditsInCurrentDir call v:lua.ShowEditsInCurrentDir()")
(vim.keymap.set :n :<esc> ":w<cr>" {:silent true})
(tset _G :GithubOpen (fn [branch]
                       (let [filepath (vim.trim (vim.fn.fnamemodify (vim.fn.expand "%")
                                                                    ":~:."))
                             row (unpack (vim.api.nvim_win_get_cursor 0))
                             command (if (= branch nil)
                                         (.. "fish -c 'gho -c " filepath "#L"
                                             row "'")
                                         (.. "fish -c 'gho " filepath "#L" row
                                             "'"))]
                         (os.capture command)
                         (vim.cmd :mode))))

(vim.keymap.set :n :<leader>x ":noh<cr>" {:silent true})
(vim.keymap.set :n :<leader>sc ":call v:lua.EditChangedFiles()<cr>"
                {:desc "Edit all changed files"})

(vim.keymap.set :n :<leader>byy ":let @*=expand(\"%:p\")<cr>"
                {:silent true :desc "Copy buffer absolute path"})

(vim.keymap.set :n :<leader>by ":let @*=expand(\"%\")<cr>"
                {:silent true :desc "Copy buffer relative path"})

(vim.keymap.set :n :<leader>boc ":call v:lua.GithubOpen()<cr>"
                {:silent true :desc "Open file in gitlab"})

(vim.keymap.set :n :<leader>bom ":call v:lua.GithubOpen('main')<cr>"
                {:silent true :desc "Open file in gitlab on the `main` branch"})

(vim.keymap.set :n :<leader>bi ":IsolateBuffer<cr>"
                {:desc "Close all buffers except current"})

(vim.keymap.set :n :<leader>bw ":WipeoutHiddenBuffers<cr>"
                {:desc "Wipeout buffers not associated to a window"})

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
              changed-files (icollect [_ raw-file (ipairs (vim.split (. (vim.split files-output
                                                                                   "\n")
                                                                        3)
                                                                     "  "))]
                              (string.gsub raw-file "%s+" ""))]
          (each [_ file (ipairs changed-files)] (vim.cmd (.. "tabedit " file))))))

(tset _G :OpenPR (fn []
                   (vim.api.nvim_exec "!git pr" true)))

(vim.cmd ":command! OpenPR call v:lua.OpenPR()")
(vim.keymap.set :n :<leader>gpr ":OpenPR<cr>" {:desc "Open draft PR"})

(tset _G :IsolateBuffer
      (fn []
        (let [cur (vim.fn.bufnr "%")
              last (vim.fn.bufnr "$")]
          (if (> cur 1) (vim.cmd (.. "silent! 1," (- cur 1) :bd)))
          (if (< cur last) (vim.cmd (.. "silent! " (+ cur 1) "," last :bd))))))

(vim.cmd ":command! -bar IsolateBuffer call v:lua.IsolateBuffer()")

(tset _G :ReloadConfig
      (fn []
        (let [luacache (. (or _G.__luacache {}) :cache)]
          (each [pkg _ (pairs package.loaded)]
            (when (and (pkg:match :^Juliet.+)
                       (not (pkg:match :^Juliet.plugins)))
              (tset package.loaded pkg nil)
              (when luacache (tset luacache pkg nil))))
          (dofile vim.env.MYVIMRC)
          (vim.notify "Config reloaded!" vim.log.levels.INFO))))

(vim.api.nvim_create_autocmd [:BufWritePost]
                             {:group (vim.api.nvim_create_augroup :WritePostReload
                                                                  {})
                              :pattern (.. (vim.fn.expand "~")
                                           :/.config/Juliet/nvim/fnl/*.fnl)
                              :callback (fn []
                                          (_G.ReloadConfig))})

(vim.cmd ":command! ReloadConfig call v:lua.ReloadConfig()")

(vim.cmd ":command! FixWhitespace %s/\\s*$//g | noh")

(tset _G :ReopenLastBuffer
      (fn []
        (vim.cmd (.. "tabedit " (vim.fn.expand "#")))))

(vim.cmd ":command! ReopenLastBuffer call v:lua.ReopenLastBuffer()")
(vim.keymap.set :n :<leader>fl ":ReopenLastBuffer<cr>")

(vim.keymap.set :t "<c-[>" "<c-\\><c-n>")
(vim.cmd ":abbreviate ag Telescope live_grep")
(vim.keymap.set :i :<c-c> :<esc>)
(vim.keymap.set :i :jk :<esc>l)
(vim.keymap.set :i :<d-v> :<c-r>* {:silent true})

(tset _G :WipeoutHiddenBuffers
      (fn []
        (local tablist
               (fcollect [i 0 (- (vim.fn.tabpagenr "$") 1)]
                 (vim.fn.tabpagebuflist (+ i 1))))
        (local known-buffers (accumulate [agg {} _ bufs (pairs tablist)]
                               (do
                                 (each [_ bufnr (ipairs bufs)]
                                   (tset agg bufnr true))
                                 agg)))
        (var n-wipeouts 0)
        (for [i 1 (vim.fn.bufnr "$")]
          (when (and (vim.fn.bufexists i) (= (vim.fn.getbufvar i :&mod) 0)
                     (= (. known-buffers i) nil))
            (vim.cmd (.. "silent exec 'bwipeout'" i))
            (set n-wipeouts (+ n-wipeouts 1))))
        (print (.. (- n-wipeouts 1) " buffer(s) wiped out"))))

(vim.cmd ":command! -bar WipeoutHiddenBuffers call v:lua.WipeoutHiddenBuffers()")

(tset _G :CloseDuplicateTabs
      (fn []
        (let [tabpages (vim.api.nvim_list_tabpages)
              open-buffers {}]
          (each [_ win (ipairs (vim.api.nvim_list_wins))]
            (local buf (vim.api.nvim_win_get_buf win))
            (if (. open-buffers buf)
                (tset open-buffers buf (+ (. open-buffers buf) 1))
                (tset open-buffers buf 1)))
          (each [_ tab (ipairs tabpages)]
            (local wins (vim.api.nvim_tabpage_list_wins tab))
            (when (= (length wins) 1)
              (local buf (vim.api.nvim_win_get_buf (. wins 1)))
              (when (> (. open-buffers buf) 1)
                (vim.api.nvim_command (.. "tabclose "
                                          (vim.api.nvim_tabpage_get_number tab)))
                (tset open-buffers buf (- (. open-buffers buf) 1))))))))

(vim.cmd ":command! -bar CloseDuplicateTabs call v:lua.CloseDuplicateTabs()")
