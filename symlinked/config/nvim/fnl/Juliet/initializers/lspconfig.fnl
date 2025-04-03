(local nvim-lsp (require :lspconfig))
(local navic (require :nvim-navic))
(local {: merge} (require :Juliet.utils))
; (local cmp-nvim-lsp (require :cmp_nvim_lsp))
(local blink-cmp (require :blink.cmp))
(local mason (require :mason))
(local mason-lspconfig (require :mason-lspconfig))
(local lspconfig-util (require :lspconfig.util))

(fn on-attach [client buffer]
  (when (= client.name :yamlls)
    (local ns (vim.lsp.diagnostic.get_namespace client.id))
    (vim.diagnostic.enable false {:ns_id ns}))
  (when client.server_capabilities.documentSymbolProvider
    (navic.attach client buffer))

  (fn buf-set-option [...] (vim.api.nvim_buf_set_option buffer ...))

  (buf-set-option :omnifunc "v:lua.vim.lsp.omnifunc")
  (vim.keymap.set :n :K "<CMD>lua vim.lsp.buf.hover()<CR>"
                  {: buffer :noremap true :silent true :desc "Show LSP hover"})
  (vim.keymap.set :n :<leader>lh "<CMD>lua vim.lsp.buf.hover()<CR>"
                  {: buffer :noremap true :silent true :desc "Show LSP hover"})
  (vim.keymap.set :n :<leader>lt "<CMD>lua vim.lsp.buf.type_definition()<CR>"
                  {: buffer
                   :noremap true
                   :silent true
                   :desc "Go to type definition"})
  (vim.keymap.set :n :<leader>lr
                  ":lua require('live-rename').rename({ insert = true })<CR>"
                  {: buffer :noremap true :silent true :desc "Rename symbol"})
  (vim.keymap.set :n :<leader>lu
                  ":lua require('telescope.builtin').lsp_references()<CR>"
                  {: buffer
                   :noremap true
                   :silent true
                   :desc "Show LSP references"})
  (vim.keymap.set :n :<leader>ld
                  ":lua require('telescope.builtin').lsp_references()<CR>"
                  {: buffer
                   :noremap true
                   :silent true
                   :desc "Show LSP references"})
  (vim.keymap.set :n :<leader>lo :<CMD>AerialToggle<CR>
                  {: buffer
                   :noremap true
                   :silent true
                   :desc "Open LSP outline"}))

; (local capabilities
;        ((. cmp-nvim-lsp :default_capabilities) (vim.lsp.protocol.make_client_capabilities)))

(local capabilities (blink-cmp.get_lsp_capabilities))

(set capabilities.textDocument.foldingRange
     {:dynamicRegistration false :lineFoldingOnly true})

(lambda get-opts [?opt-overrides]
  (local opt-settings {})
  (local opt-overrides (or ?opt-overrides {}))
  (local opts {:capabilities (blink-cmp.get_lsp_capabilities opt-overrides)
               :flags {:debounce_text_changes 150}
               :handlers {:textDocument/hover (vim.lsp.with vim.lsp.handlers.hover
                                                {:border :rounded})}
               :on_attach on-attach
               :root_dir (nvim-lsp.util.root_pattern :.git)})
  (local settings (merge opt-settings (or opt-overrides.settings {})))
  (merge opts opt-overrides {: settings}))

(vim.cmd " do User LspAttachBuffers ")
(mason.setup)
(local servers [{:name :bashls}
                {:name :cssls}
                {:name :fennel_language_server
                 :opts {:settings {:fennel {:diagnostics {:globals [:vim]}
                                            :workspace {:library (vim.api.nvim_list_runtime_paths)}}}}}
                {:name :gopls
                 :opts {:root_dir (lspconfig-util.root_pattern :go.mod)}}
                {:name :lua_ls
                 :opts {:settings {:Lua {:diagnostics {:globals [:vim]}
                                         :runtime {:version :LuaJIT}
                                         :telemetry {:enable false}
                                         :workspace {:checkThirdParty false
                                                     :library (vim.api.nvim_get_runtime_file ""
                                                                                             true)}}}}}
                {:name :solidity}
                {:name :tailwindcss}
                {:name :vtsls}
                {:name :yamlls}
                {:name :pylsp
                 :opts {:settings {:pylsp {:plugins {:pycodestyle {:enabled false}
                                                     :pyflakes {:enabled false}}}}}}
                {:name :terraformls}
                {:name :rust_analyzer}
                {:name :zls}])

(mason-lspconfig.setup {:ensure_installed (icollect [_ {: name} (ipairs servers)]
                                            name)})

(lambda setup-server [server ?opt-overrides]
  ((. (. nvim-lsp server) :setup) (get-opts ?opt-overrides)))

(each [_ {: name : opts} (ipairs servers)]
  (setup-server name opts))
