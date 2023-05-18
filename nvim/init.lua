vim.loader.enable()

function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then
		return s
	end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

vim.opt.encoding = 'UTF-8'
vim.cmd('set noswapfile')
vim.opt.switchbuf = 'uselast'
vim.cmd([[
augroup quickfix
  autocmd!
  au FileType qf wincmd J
augroup END
]])

vim.cmd([[
set termguicolors
]])
vim.cmd([[
set scrolloff=4
]])

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.shortmess = ''
vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
vim.g.DevIconsEnableFoldersOpenClose = 1
-- vim.g.startify_change_to_vcs_root = 1
vim.g.DevIconsDefaultFolderOpenSymbol = ''
vim.g.WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = ''
vim.g.go_fmt_command = 'goimports'
-- vim.lsp.set_log_level("debug")
vim.opt.timeoutlen = 500
vim.opt.guifont = 'Iosevka Term:h18'

vim.cmd('filetype plugin indent on')

vim.opt.mouse = 'a'
vim.opt.mousemoveevent = true
-- vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 3
vim.cmd('hi Directory guifg=#FF0000 ctermfg=red')
vim.opt.backspace = 'indent,eol,start'
vim.opt.clipboard = 'unnamed'
vim.opt.shell = 'fish'
vim.opt.fdm = 'syntax'
vim.cmd('autocmd InsertEnter * set cursorline')
vim.cmd('autocmd InsertLeave * set nocursorline')
vim.cmd('set completeopt-=preview')
vim.cmd('set noshowmode')

-- theme
vim.opt.termguicolors = true

-- indentation
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.foldmethod = 'expr'

vim.opt.foldcolumn = '1'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.hidden = true

vim.cmd([[
augroup FiletypeGroup
  autocmd!
  au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
  au BufNewFile,BufRead *.mdx set filetype=markdown.mdx
  au BufRead,BufNewFile *.md setlocal textwidth=80
  au FileType fish setlocal textwidth=79
  au FileType fish setlocal foldmethod=expr
  autocmd BufNewFile,BufRead Brewfile set filetype=ruby
  autocmd BufNewFile,BufRead Procfile set filetype=sh
augroup END
]])

vim.cmd('highlight MatchParen cterm=bold ctermfg=white ctermbg=black')
-- vim.cmd('source ~/.config/Juliet/nvim/_init.vim')

local lazy_plugins_path = vim.fn.stdpath('data') .. '/lazy'
-- bootstrap lazy.nvim
local lazy_path = lazy_plugins_path .. '/lazy.nvim'
if not vim.loop.fs_stat(lazy_path) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazy_path,
	})
end
vim.opt.rtp:prepend(lazy_path)

-- bootstrap hotpot.nvim
local hotpot_path = lazy_plugins_path .. '/hotpot.nvim'
if not vim.loop.fs_stat(hotpot_path) then
	vim.notify('Bootstrapping hotpot.nvim...', vim.log.levels.INFO)
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'--single-branch',
		'https://github.com/rktjmp/hotpot.nvim.git',
		hotpot_path,
	})
end
vim.opt.rtp:prepend(hotpot_path)

-- bootstrap themis.nvim
local themis_path = lazy_plugins_path .. '/themis.nvim'
if not vim.loop.fs_stat(themis_path) then
	vim.notify('Bootstrapping themis.nvim...', vim.log.levels.INFO)
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'--single-branch',
		'https://github.com/datwaft/themis.nvim.git',
		themis_path,
	})
end
vim.opt.runtimepath:prepend(themis_path)

require('hotpot').setup({
	provide_require_fennel = true,
	compiler = {
		modules = {
			correlate = true,
		},
	},
})

require('plugins')
require('mappings')
require('initializers.index')
