vim.cmd([[
augroup filetype_ts
autocmd!
autocmd BufNewFile,BufRead *.tsx,*.jsx,*.ts set filetype=typescriptreact syntax=typescript.tsx
augroup END
]])

local nvim_lsp = require('lspconfig')
local lsp_installer = require("nvim-lsp-installer")
local lsp_installer_servers = require("nvim-lsp-installer.servers")

lsp_installer.on_server_ready(function(server)
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap=true, silent=true })
    buf_set_keymap('n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap=true, silent=true })
    buf_set_keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap=true, silent=true })
    buf_set_keymap('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap=true, silent=true })
  end

  local opts = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    handlers = {
      ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
    }
  }

  server:setup(opts)
  vim.cmd [[ do User LspAttachBuffers ]]
end)

local servers = {
  "bashls",
  "cssls",
  "html",
  -- "jsonls",
  "tailwindcss",
  "tsserver",
  -- "ocamlls",
}

function UninstallLspServers()
  vim.cmd("LspUninstallAll")
end
function InstallLspServers()
  for _, name in pairs(servers) do
    vim.cmd("LspInstall " .. name)
  end
end
vim.cmd(":abbreviate LSPI call v:lua.InstallLspServers()")
vim.cmd(":abbreviate LSPU call v:lua.UninstallLspServers()")

function SyncLsps()
  for _, name in pairs(servers) do
    local server_available, requested_server = lsp_installer_servers.get_server(name)

    if server_available then
      if not requested_server:is_installed() then
        print("Installing lsp: " .. requested_server.name)
        requested_server:install()
      end
    end
  end
end

vim.cmd(":abbreviate LspSync echo 'Installing servers...' | call v:lua.SyncLsps()")
