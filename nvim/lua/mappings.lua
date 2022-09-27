local utils = require("utils")

local function create_map_func(mode)
	return function(binding, command, opts)
		opts = opts or {}
		final_opts = { noremap = true }

		utils.merge(final_opts, opts)

		vim.api.nvim_set_keymap(mode, binding, command, final_opts)
	end
end

-- normal mappings --

local normal_map = create_map_func("n")

normal_map("<leader>t", ':lua require("cmds/switch_bufferline_mode")()<cr>', { silent = true })
normal_map("<leader>ev", ":tabe ~/.config/Juliet/nvim/init.lua<cr>")
normal_map("<leader>sv", ":source $MYVIMRC<cr>")
normal_map("<leader>it", ":put =strftime('%FT%T%z')<cr>")
normal_map("<leader>id", 'a<C-R>=strftime("%Y-%m-%d")<cr><esc>')
normal_map("H", "^")
normal_map("L", "g$")
normal_map("q:", "<nop>")
normal_map("<leader>dd", ":TroubleToggle document_diagnostics<cr>")
normal_map("<leader>d", ":TroubleToggle<cr>")
normal_map("<leader>d5", ":TroubleRefresh<cr>")

function ToggleNumbers()
	vim.cmd('exec &number == 0 ? "set number norelativenumber" : "set relativenumber nonumber"')
end

vim.cmd(":command ToggleNumbers call v:lua.ToggleNumbers()")

normal_map("<c-p>", ":Telescope find_files<cr>", { silent = true })
normal_map("<c-b>", ":Telescope buffers<cr>", { silent = true })
normal_map("<c-o>", ":w<cr>")
normal_map("<leader>cp", ':let @*=expand("%:p")<cr>')
normal_map("<leader>cf", ':let @*=expand("%")<cr>')
normal_map("<c-f>", ":ZenMode<cr>", { silent = true })
normal_map("<leader>f", ":NvimTreeToggle<CR>")
normal_map("<leader>fr", ":NvimTreeRefresh<CR>")
normal_map("<leader>ff", ":NvimTreeFindFile<CR>")
normal_map("<leader>fb", ":Telescope file_browser<CR>")
normal_map("<leader>x", ":noh<cr>")
normal_map("<tab>", ":BufferLineCycleNext<cr>")
normal_map("<s-tab>", ":BufferLineCyclePrev<cr>")
normal_map("<leader>ss", ":SessionManager save_current_session<cr>")
normal_map("<leader>sl", ":SessionManager load_current_dir_session<cr>")
normal_map("<leader>sc", ":call v:lua.EditChangedFiles()<cr>")
normal_map("<leader>b", ":BufferLinePick<cr>")
normal_map("<leader>bb", ":BufferLinePick<cr>")
normal_map("<leader>bc", ":BufferLinePickClose<cr>")
normal_map("<leader>bf", ":Neoformat<cr>")
normal_map("<leader>sc", ":let @a=@*<cr>")
normal_map("<leader>sca", ":let @a=@*<cr>")
normal_map("<leader>scb", ":let @b=@*<cr>")
normal_map("<leader>scc", ":let @c=@*<cr>")
normal_map("<leader>scd", ":let @d=@*<cr>")

function EditChangedFiles()
	local files_output = vim.api.nvim_exec('!changed_files', true)
	local changed_files = vim.split(files_output, '\n')[3]

	vim.cmd('args' .. changed_files)
end

-- terminal mappings --

local terminal_map = create_map_func("t")

terminal_map("<c-[>", "<leader><c-n>")

vim.cmd(":abbreviate ag Telescope live_grep")

-- insert mappings --

local insert_map = create_map_func("i")

insert_map("<c-c>", "<esc>")
insert_map("<d-v>", "<c-r>*", { silent = true })

vim.cmd([[
nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
]])
