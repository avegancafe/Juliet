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

buffer_current_tabmode = 'buffers'

local plugins = {
	{
		'rktjmp/hotpot.nvim',
		dependencies = { 'datwaft/themis.nvim' },
	},
}

require('hotpot').setup({
	provide_require_fennel = true,
	compiler = {
		modules = {
			correlate = true,
		},
	},
})

-- require("conf")

local fnl_definition_paths = vim.fn.stdpath('config') .. '/fnl/conf/plugins'
if vim.loop.fs_stat(fnl_definition_paths) then
	for file in vim.fs.dir(fnl_definition_paths) do
		file = file:match('^(.*)%.fnl$')
		plugins[#plugins + 1] = require('conf.plugins.' .. file)
	end
end

require('lazy').setup(plugins, { ui = { border = 'rounded' } })
