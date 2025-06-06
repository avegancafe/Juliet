(vim.keymap.set :n :<leader>it ":put =strftime('%FT%T%z')<cr>"
                {:desc "Insert timestamp below this line"})

(vim.keymap.set :n :<leader>id "a<C-R>=strftime(\"%Y-%m-%d\")<cr><esc>"
                {:desc "Insert current date at cursor"})

(vim.keymap.set :n :H "^")
(vim.keymap.set :n :L :g$)
(vim.keymap.set :x :p "p<cmd>let @+=@0<CR><cmd>let @\"=@0<CR>"
                {:noremap true :silent true})

; center cursor on screen when navigating
(vim.keymap.set :n "<c-]>" "<c-]>zt" {:silent true})
(vim.keymap.set :n :<c-u> :<c-u>zz {:silent true})
(vim.keymap.set :n :<c-d> :<c-d>zz {:silent true})
(vim.keymap.set :n :n :nzz)
(vim.keymap.set :n :N :Nzz)

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
(vim.keymap.set :n :<left> :zt)
(vim.keymap.set :n :<right> :zb)
(vim.keymap.set :n :<up> :<c-y>)
(vim.keymap.set :n :<down> :<c-e>)

(if (= (vim.fn.exists "g:neovide") 1)
    (do
      (vim.keymap.set :n :<d-s> ":w<cr>")
      (vim.keymap.set :v :<d-c> :+y)
      (vim.keymap.set :n :<d-v> :+P)
      (vim.keymap.set :v :<d-v> :+P)
      (vim.keymap.set :c :<d-v> :<C-R>+)
      (vim.keymap.set :i :<d-v> "<ESC>l\"+Pa")))

(vim.api.nvim_set_keymap "" :<d-v> :+p {:noremap true :silent true})
(vim.api.nvim_set_keymap "!" :<d-v> :<C-R>+ {:noremap true :silent true})
(vim.api.nvim_set_keymap :t :<d-v> "<c-\\><c-n>pa" {:noremap true :silent true})
(vim.api.nvim_set_keymap :v :<d-v> :<C-R>+ {:noremap true :silent true})

(fn toggle-numbers []
  (if (= vim.opt.relativenumber._value true)
      (do
        (tset vim.opt :relativenumber false)
        (vim.cmd ":tabdo windo set norelativenumber"))
      (do
        (tset vim.opt :relativenumber true)
        (vim.cmd ":tabdo windo set relativenumber"))))

(vim.api.nvim_create_user_command :ToggleNumbers toggle-numbers {:bar true})

(vim.keymap.set :n :<esc> ":w<cr>" {:silent true})
(fn open-github [branch]
  (let [filepath (vim.trim (vim.fn.fnamemodify (vim.fn.expand "%") ":~:."))
        row (unpack (vim.api.nvim_win_get_cursor 0))
        command (if (= branch nil)
                    (.. "fish -c 'gho -c " filepath "#L" row "'")
                    (.. "fish -c 'gho " filepath "#L" row "'"))]
    (os.capture command)
    (vim.cmd :mode)))

(vim.keymap.set :n :<leader>x ":noh<cr>" {:silent true})
(vim.keymap.set :n :<leader>sc ":call v:lua.EditChangedFiles()<cr>"
                {:desc "Edit all changed files"})

(vim.keymap.set :n :<leader>byy
                (fn []
                  (let [path (vim.fn.expand "%:p")]
                    (print (.. "Copied '" path "' to clipboard"))
                    (vim.fn.setreg "*" path)))
                {:silent true :desc "Copy buffer absolute path"})

(vim.keymap.set :n :<leader>byr
                (fn []
                  (let [path (vim.fn.expand "%:.")]
                    (print (.. "Copied '" path "' to clipboard"))
                    (vim.fn.setreg "*" path)))
                {:silent true :desc "Copy buffer relative path"})

(vim.keymap.set :n :<leader>byf
                (fn []
                  (let [filename (vim.fn.expand "%:t")]
                    (print (.. "Copied '" filename "' to clipboard"))
                    (vim.fn.setreg "*" filename)))
                {:silent true :desc "Copy buffer file name"})

(vim.keymap.set :n :<leader>by ":let @*=expand(\"%\")<cr>"
                {:silent true :desc "Copy buffer relative path"})

(vim.keymap.set :n :<leader>boc open-github
                {:silent true :desc "Open file in gitlab"})

(vim.keymap.set :n :<leader>bom (fn [] (open-github :main))
                {:silent true :desc "Open file in gitlab on the `main` branch"})

(vim.keymap.set :n :<leader>bi
                ":IsolateBuffer | CloseDuplicateTabs | WipeoutHiddenBuffers<cr>"
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

(fn open-pr []
  (vim.api.nvim_exec "!git pr" true))

(vim.api.nvim_create_user_command :OpenPR open-pr {})

(vim.keymap.set :n :<leader>gpr open-pr {:desc "Open draft PR"})

(fn isolate-buffer []
  (let [cur (vim.fn.bufnr "%")
        last (vim.fn.bufnr "$")]
    (if (> cur 1) (vim.cmd (.. "silent! 1," (- cur 1) :bd)))
    (if (< cur last) (vim.cmd (.. "silent! " (+ cur 1) "," last :bd)))))

(vim.api.nvim_create_user_command :IsolateBuffer isolate-buffer {:bar true})

(fn reload-config []
  (let [luacache (. (or _G.__luacache {}) :cache)]
    (each [pkg _ (pairs package.loaded)]
      (when (and (pkg:match :^Juliet.+) (not (pkg:match :^Juliet.plugins)))
        (tset package.loaded pkg nil)
        (when luacache (tset luacache pkg nil))))
    (dofile vim.env.MYVIMRC)
    (vim.notify "Config reloaded!" vim.log.levels.INFO)))

(vim.api.nvim_create_user_command :ReloadConfig reload-config {})

(vim.api.nvim_create_autocmd [:BufWritePost]
                             {:group (vim.api.nvim_create_augroup :WritePostReload
                                                                  {})
                              :pattern (.. (vim.fn.expand "~")
                                           :/.config/Juliet/nvim/fnl/*.fnl)
                              :callback (fn []
                                          (reload-config))})

(vim.cmd ":command! FixWhitespace %s/\\s*$//g | noh")
(vim.api.nvim_create_user_command :FixWhitespace "%s/\\s*$//g | noh"
                                  {:bar true})

(fn reopen-last-buffer []
  (vim.cmd (.. "tabedit " (vim.fn.expand "#"))))

(vim.api.nvim_create_user_command :ReopenLastBuffer reopen-last-buffer {})

(vim.keymap.set :n :<leader>fl ":ReopenLastBuffer<cr>")

(vim.keymap.set :t "<c-[>" "<c-\\><c-n>")
(vim.cmd ":abbreviate ag Telescope live_grep")
(vim.keymap.set :i :<c-c> :<esc>)
(vim.keymap.set :i :jk :<esc>l)
(vim.keymap.set :i :<d-v> :<c-r>* {:silent true})

(fn wipeout-hidden-buffers []
  (local tablist (fcollect [i 0 (- (vim.fn.tabpagenr "$") 1)]
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
  (print (.. (math.max 0 (- n-wipeouts 1)) " buffer(s) wiped out")))

(vim.api.nvim_create_user_command :WipeoutHiddenBuffers wipeout-hidden-buffers
                                  {:bar true})

(fn close-duplocate-tabs []
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
          (tset open-buffers buf (- (. open-buffers buf) 1)))))))

(vim.api.nvim_create_user_command :CloseDuplicateTabs close-duplocate-tabs
                                  {:bar true})
