local utils = require('utils')

local function create_map_func(mode)
	return function(binding, command, opts)
		opts = opts or {}
		local final_opts = { noremap = true }

		utils.merge(final_opts, opts)

		vim.api.nvim_set_keymap(mode, binding, command, final_opts)
	end
end

-- normal mappings --

local normal_map = create_map_func('n')

normal_map('<leader>t', ':lua require("cmds/switch_bufferline_mode")()<cr>', { silent = true })
normal_map('<leader>p', ':Lazy<cr>', { silent = true })
normal_map('<leader>ev', ':tabe ~/.config/Juliet/nvim/init.lua<cr>')
normal_map('<leader>sv', ':source $MYVIMRC<cr>')
normal_map('<leader>it', ":put =strftime('%FT%T%z')<cr>")
normal_map('<leader>id', 'a<C-R>=strftime("%Y-%m-%d")<cr><esc>')
normal_map('H', '^')
normal_map('L', 'g$')
normal_map('q:', '<nop>')
normal_map('<leader>dd', ':TroubleToggle document_diagnostics<cr>')
normal_map('<leader>d', ':TroubleToggle<cr>')
normal_map('<leader>d5', ':TroubleRefresh<cr>')
normal_map('<leader>h', ':Dashboard<cr>')
normal_map('gQ', ':echo "Ex mode disabled. Re-enable in your mappigns if you\'d like to use it."<cr>')
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

function ToggleNumbers()
	vim.cmd('exec &number == 0 ? "set number norelativenumber" : "set relativenumber nonumber"')
end

vim.cmd(':command ToggleNumbers call v:lua.ToggleNumbers()')
vim.cmd(':abbreviate bgt BufferLineGroupToggle')

function ShowEditsInCurrentDir()
	local cwd = vim.fn.fnamemodify(vim.fn.expand('%:h'), ':~:.')
	vim.cmd('TodoTrouble keywords=EDIT cwd=' .. cwd)
end

vim.cmd(':command ShowEditsInCurrentDir call v:lua.ShowEditsInCurrentDir()')

normal_map('<c-p>', ':Telescope find_files<cr>', { silent = true })
normal_map('<c-b>', ':Telescope buffers<cr>', { silent = true })
normal_map('<c-o>', ':w<cr>', { silent = true })

function GitlabOpen()
	local filepath = vim.trim(vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.'))
	local command = "fish -c 'glo -c " .. filepath .. "'"

	os.capture(command)
	vim.cmd('mode')
end
normal_map('<leader>cp', ':let @*=expand("%:p")<cr>', { silent = true })
normal_map('<c-f>', ':ZenMode<cr>', { silent = true })
normal_map('<leader>f', ':NvimTreeToggle<CR>', { silent = true })
normal_map('<leader>fr', ':NvimTreeRefresh<CR>', { silent = true })
normal_map('<leader>ff', ':NvimTreeFindFile<CR>', { silent = true })
normal_map('<leader>fb', ':Telescope file_browser<CR>', { silent = true })
normal_map('<leader>x', ':noh<cr>', { silent = true })
normal_map('<tab>', ':BufferLineCycleNext<cr>', { silent = true })
normal_map('<s-tab>', ':BufferLineCyclePrev<cr>', { silent = true })
normal_map('<leader>ss', ':SessionManager save_current_session<cr>')
normal_map('<leader>sl', ':Telescope workspaces<cr>', { silent = true })
normal_map('<leader>sc', ':call v:lua.EditChangedFiles()<cr>')
normal_map('<leader>b', ':BufferLinePick<cr>', { silent = true })
normal_map('<leader>bb', ':BufferLinePick<cr>', { silent = true })
normal_map('<leader>bc', ':BufferLinePickClose<cr>', { silent = true })
normal_map('<leader>bg', ':`:BufferLineGroupToggle`<cr>', { silent = true })
normal_map('<leader>bf', ':Neoformat<cr>', { silent = true })
normal_map('<leader>bs', ':Vista<cr>')
normal_map('<leader>bo', ':call v:lua.GitlabOpen()<cr>', { silent = true })
normal_map('<leader>rs', ':let @a=@*<cr>', { silent = true })
normal_map('<leader>rsa', ':let @a=@*<cr>', { silent = true })
normal_map('<leader>rsb', ':let @b=@*<cr>', { silent = true })
normal_map('<leader>rsc', ':let @c=@*<cr>', { silent = true })
normal_map('<leader>rsd', ':let @d=@*<cr>', { silent = true })

normal_map('<leader>dc', ':lua require"dap".continue()<cr>', { silent = true })
normal_map('<leader>ds', ':lua require"dap".step_over()<cr>', { silent = true })
normal_map('<leader>dso', ':lua require"dap".step_over()<cr>', { silent = true })
normal_map('<leader>dsi', ':lua require"dap".step_into()<cr>', { silent = true })
normal_map('<leader>dsu', ':lua require"dap".step_out()<cr>', { silent = true })
normal_map('<leader>db', ':lua require"dap".toggle_breakpoint()<cr>', { silent = true })
normal_map('<leader>dr', ':lua require"dap".repl.open()<cr>', { silent = true })

function EditChangedFiles()
	local files_output = vim.api.nvim_exec('!changed_files', true)
	local changed_files = vim.split(files_output, '\n')[3]

	vim.cmd('args ' .. changed_files)
end

-- terminal mappings --

local terminal_map = create_map_func('t')

terminal_map('<c-[>', '<c-\\><c-n>')

vim.cmd(':abbreviate ag Telescope live_grep')

-- insert mappings --

local insert_map = create_map_func('i')

insert_map('<c-c>', '<esc>')
insert_map('<d-v>', '<c-r>*', { silent = true })

vim.cmd([[
nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
]])
