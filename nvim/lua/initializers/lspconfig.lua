vim.cmd([[
augroup filetype_ts
autocmd!
autocmd BufNewFile,BufRead *.tsx,*.jsx,*.ts set filetype=typescriptreact syntax=typescript.tsx
augroup END
]])

local nvim_lsp = require('lspconfig')
local lsp_installer = require("nvim-lsp-installer")

lsp_installer.on_server_ready(function(server)
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap=true, silent=true })
  end

  local opts = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
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
}

function UninstallLspServers()
  vim.cmd("LspUninstallAll")
end
function InstallLspServers()
  for _, name in pairs(servers) do
    vim.cmd("LspInstall " .. name)
  end
end
vim.cmd(":ab LSPI call v:lua.InstallLspServers()")
vim.cmd(":ab LSPU call v:lua.UninstallLspServers()")
