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

local lazy_plugins_path = vim.fn.stdpath('data') .. '/lazy'
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

require('hotpot').setup({
	provide_require_fennel = true,
	compiler = {
		modules = {
			correlate = true,
		},
	},
})

require('Juliet')
require('Juliet.plugins')
require('Juliet.mappings')
require('Juliet.initializers')

if vim.g.juliet__restore_lazy_plugins then
	require('lazy.manage').restore()
end
