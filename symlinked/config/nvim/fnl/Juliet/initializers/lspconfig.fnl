(local nvim-lsp (require :lspconfig))
(local navic (require :nvim-navic))
(local {: merge} (require :Juliet.utils))
(local cmp-nvim-lsp (require :cmp_nvim_lsp))
(local mason (require :mason))
(local mason-lspconfig (require :mason-lspconfig))
(local lspconfig-util (require :lspconfig.util))

(fn on-attach [client bufnr]
  (when (= client.name :yamlls)
    (local ns (vim.lsp.diagnostic.get_namespace client.id))
    (vim.diagnostic.disable nil ns))
  (when client.server_capabilities.documentSymbolProvider
    (navic.attach client bufnr))

  (fn buf-set-keymap [...] (vim.api.nvim_buf_set_keymap bufnr ...))

  (fn buf-set-option [...] (vim.api.nvim_buf_set_option bufnr ...))

  (buf-set-option :omnifunc "v:lua.vim.lsp.omnifunc")
  (buf-set-keymap :n :K "<CMD>lua vim.lsp.buf.hover()<CR>"
                  {:noremap true :silent true})
  (buf-set-keymap :n :<leader>lh "<CMD>lua vim.lsp.buf.hover()<CR>"
                  {:noremap true :silent true})
  (buf-set-keymap :n :<leader>ld
                  ":lua require('telescope.builtin').lsp_references()<CR>"
                  {:noremap true :silent true})
  (buf-set-keymap :n :<leader>li
                  ":lua require('telescope.builtin').lsp_references()<CR>"
                  {:noremap true :silent true})
  (buf-set-keymap :n :<leader>lr ":IncRename " {:noremap true :silent true})
  (buf-set-keymap :n :<leader>lu
                  ":lua require('telescope.builtin').lsp_references()<CR>"
                  {:noremap true :silent true})
  (buf-set-keymap :n :<leader>lo :<CMD>AerialToggle<CR>
                  {:noremap true :silent true}))

(local capabilities
       ((. cmp-nvim-lsp :default_capabilities) (vim.lsp.protocol.make_client_capabilities)))

(set capabilities.textDocument.foldingRange
     {:dynamicRegistration false :lineFoldingOnly true})

(lambda get-opts [?opt-overrides]
  (local opts
         {: capabilities
          :flags {:debounce_text_changes 150}
          :handlers {:textDocument/hover (vim.lsp.with vim.lsp.handlers.hover
                                           {:border :rounded})}
          :on_attach on-attach
          :root_dir (nvim-lsp.util.root_pattern :.git)
          :settings {:Lua {:diagnostics {:globals [:vim]}
                           :runtime {:version :LuaJIT}
                           :telemetry {:enable false}
                           :workspace {:checkThirdParty false
                                       :library (vim.api.nvim_get_runtime_file ""
                                                                               true)}}
                     :fennel {:diagnostics {:globals [:vim]}
                              :workspace {:library (vim.api.nvim_list_runtime_paths)}}}})
  (merge opts (or ?opt-overrides {})))

(vim.cmd " do User LspAttachBuffers ")
(mason.setup)
(local servers [{:name :bashls}
                {:name :bufls}
                {:name :cssls}
                {:name :fennel_language_server}
                {:name :gopls
                 :opts {:root_dir (lspconfig-util.root_pattern :go.mod)}}
                {:name :lua_ls}
                {:name :solidity}
                {:name :tailwindcss}
                {:name :vtsls}
                {:name :yamlls}
                {:name :pylsp}
                {:name :terraformls}
                {:name :rust_analyzer}])

(mason-lspconfig.setup {:ensure_installed (icollect [_ {: name} (ipairs servers)]
                                            name)})

(lambda setup-server [server ?opt-overrides]
  ((. (. nvim-lsp server) :setup) (get-opts ?opt-overrides)))

(each [_ {: name : opts} (ipairs servers)]
  (setup-server name opts))
