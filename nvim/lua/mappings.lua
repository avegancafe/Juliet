local utils = require('utils')

local function create_map_func(mode)
  return function(binding, command, opts)
    opts = opts or {}
    final_opts = { noremap = true }

    utils.merge(final_opts, opts)

    vim.api.nvim_set_keymap(mode, binding, command, final_opts)
  end
end

-- normal mappings --

local normal_map = create_map_func('n')

normal_map('t<leader>f', ':TestFile<cr>')
normal_map('t<leader>l', ':TestLast<cr>')
normal_map('<leader>t', ':Tnew<cr>')
normal_map('<leader>ev', ':tabe ~/.config/Juliet/nvim/init.lua<cr>')
normal_map('<leader>sv', ':source $MYVIMRC<cr>')
normal_map('<leader>it', ':put =strftime(\'%FT%T%z\')<cr>')
normal_map('<leader>id', 'a<C-R>=strftime("%Y-%m-%d")<CR><Esc>')
normal_map('H', '^')
normal_map('L', 'g$')
normal_map('q:', '<nop>')
normal_map('<leader>d', ':g/;;/d<cr>')
normal_map('<leader>l', ':exec &number == 0 ? "set number norelativenumber" : "set relativenumber nonumber"<cr>', { silent = true })
normal_map('<c-p>', ':Telescope find_files<cr>', { silent = true })
normal_map('<c-b>', ':Telescope buffers<cr>', { silent = true })
normal_map('<c-o>', ':w<cr>')
normal_map('cq', ':let @*=expand("%:p")<cr>')
normal_map('cw', ':let @*=expand("%")<cr>')
normal_map('<c-f>', ':Goyo<cr>', { silent = true })
normal_map('<leader>f', ':Neoformat<cr>')
normal_map('<c-n>', ':NvimTreeToggle<CR>')
normal_map('<leader>r', ':NvimTreeRefresh<CR>')
normal_map('<leader>n', ':NvimTreeFindFile<CR>')
normal_map('<leader>x', ':noh<cr>')
normal_map('<tab>', ':BufferLineCyclePrev<cr>')
normal_map('<s-tab>', ':BufferLineCycleNext<cr>')
normal_map('<leader>ss', ':SessionSave<cr>')
normal_map('<leader>sl', ':SessionLoad<cr>')

-- terminal mappings --

local terminal_map = create_map_func('t')

terminal_map('<c-[>', '<c-\\><c-n>')

-- command mappings --

local command_map = create_map_func('c')

command_map('X', 'x')
command_map('ag', 'Telescope live_grep')

-- insert mappings --

local insert_map = create_map_func('i')

insert_map('<c-c>', '<esc>')
insert_map('<d-v>', '<c-r>*', { silent = true })
