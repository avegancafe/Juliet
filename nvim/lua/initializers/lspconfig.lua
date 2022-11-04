vim.cmd([[
augroup filetype_ts
autocmd!
autocmd BufNewFile,BufRead *.tsx,*.jsx,*.ts set filetype=typescriptreact syntax=typescript.tsx
augroup END
]])

local nvim_lsp = require('lspconfig')
local lsp_installer = require('nvim-lsp-installer')
local lsp_installer_servers = require('nvim-lsp-installer.servers')

lsp_installer.setup({})

local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end
	buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
	buf_set_keymap('n', 'K', '<CMD>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>lh', '<CMD>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>ld', '<CMD>Trouble lsp_definitions<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>li', '<CMD>Trouble lsp_implementations<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>lr', '<CMD>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>la', '<CMD>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>lu', '<CMD>Trouble lsp_references<CR>', { noremap = true, silent = true })
end

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local opts = {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
		debounce_text_changes = 150,
	},
	handlers = {
		['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
	},
	root_dir = nvim_lsp.util.root_pattern('.git'),
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { 'vim' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file('', true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

vim.cmd([[ do User LspAttachBuffers ]])

local servers = {
	'bashls',
	'cssls',
	'html',
	'tailwindcss',
	'tsserver',
	'gopls',
	'solidity_ls',
	'sumneko_lua',
}

function UninstallLspServers()
	vim.cmd('LspUninstallAll')
end
function InstallLspServers()
	for _, name in pairs(servers) do
		vim.cmd('LspInstall ' .. name)
	end
end
vim.cmd(':abbreviate LSPI call v:lua.InstallLspServers()')
vim.cmd(':abbreviate LSPU call v:lua.UninstallLspServers()')

function SyncLsps()
	for _, name in pairs(servers) do
		local server_available, requested_server = lsp_installer_servers.get_server(name)

		if server_available then
			if not requested_server:is_installed() then
				print('Installing lsp: ' .. requested_server.name)
				requested_server:install()
			end
		end
	end
end

vim.cmd(":abbreviate LspSync echo 'Installing servers...' | call v:lua.SyncLsps()")

for _, name in pairs(servers) do
	nvim_lsp[name].setup(opts)
end
