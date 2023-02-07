vim.cmd([[
augroup filetype_ts
autocmd!
autocmd BufNewFile,BufRead *.tsx,*.jsx,*.ts set filetype=typescriptreact syntax=typescript.tsx
augroup END
]])

local nvim_lsp = require('lspconfig')
local navic = require('nvim-navic')

local on_attach = function(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end

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
	buf_set_keymap('n', '<leader>lr', ':IncRename ', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>la', '<CMD>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>lu', '<CMD>Trouble lsp_references<CR>', { noremap = true, silent = true })
end

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

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
	'solidity',
	'yamlls',
l}

require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = servers,
})

require('mason-lspconfig').setup_handlers({
	function(server_name)
		require('lspconfig')[server_name].setup(opts)
	end,
})
