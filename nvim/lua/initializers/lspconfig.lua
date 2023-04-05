function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

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
	buf_set_keymap('n', '<leader>ld', '<CMD>Lspsaga lsp_finder<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>li', '<CMD>Lspsaga lsp_finder<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>lr', ':IncRename ', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>la', '<CMD>Lspsaga code_action<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>lu', '<CMD>Lspsaga lsp_finder<CR>', { noremap = true, silent = true })
	buf_set_keymap('n', '<leader>lo', '<CMD>Lspsaga outline<CR>', { noremap = true, silent = true })
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
				checkThirdParty = false
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

vim.cmd([[ do User LspAttachBuffers ]])

require('mason').setup()
require('lspconfig').tsserver.setup(opts)

local servers = {
	'bashls',
	'bufls',
	'fennel_language_server',
	'gopls',
	'lua_ls',
	'solidity',
	'tailwindcss',
	'yamlls',
	'tsserver',
}

require('mason-lspconfig').setup({
	ensure_installed = servers,
})

require('mason-lspconfig').setup_handlers({
	function(server_name)
		require('lspconfig')[server_name].setup(opts)
	end,

	['gopls'] = function()
		local gopls_opts = deepcopy(opts)

		local util = require('lspconfig/util')
		gopls_opts.root_dir = util.root_pattern('go.mod')

		require('lspconfig').gopls.setup(gopls_opts)
	end,

	['fennel_language_server'] = function()
		fls_opts = deepcopy(opts)

		fls_opts.default_config = {
			-- replace it with true path
			cmd = { '~/.local/share/nvim/mason/packages/fennel-language-server/bin/fennel-language-server' },
			filetypes = { 'fennel' },
			single_file_support = true,
			-- source code resides in directory `fnl/`
			root_dir = require('lspconfig').util.root_pattern('fnl'),
			settings = {
				fennel = {
					workspace = {
						-- If you are using hotpot.nvim or aniseed,
						-- make the server aware of neovim runtime files.
						library = vim.api.nvim_list_runtime_paths(),
					},
					diagnostics = {
						globals = { 'vim' },
					},
				},
			},
		}

		require('lspconfig').fennel_language_server.setup(fls_opts)
	end,
})
