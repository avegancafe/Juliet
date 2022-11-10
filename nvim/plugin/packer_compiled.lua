-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = true
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/kyle/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/kyle/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/kyle/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/kyle/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/kyle/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\nO\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\fbuffers\nsetup\26cmds/setup_bufferline\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/opt/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["committia.vim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/committia.vim",
    url = "https://github.com/rhysd/committia.vim"
  },
  ["dashboard-nvim"] = {
    config = { "\27LJ\2\nŸ\1\0\0\a\2\6\2\0205\0\0\0-\1\0\0009\1\1\1\18\3\0\0B\1\2\2\21\2\1\0\t\2\0\0X\2\4Ä-\2\1\0005\3\3\0=\3\2\2X\2\aÄ-\2\1\0005\3\4\0006\4\5\0\18\6\1\0B\4\2\0?\4\1\0=\3\2\2K\0\1\0\1¿\0¿\vunpack\1\5\0\0\5\5\15Git status\5\1\6\0\0\5\5\15Git status\5\21No files changed\18custom_footer\26get_os_command_output\1\6\0\0\bgit\vstatus\a-s\a--\6.\0\vÄÄ¿ô\4˘\b\1\0\15\0\29\1A6\0\0\0'\2\1\0B\0\2\0025\1\3\0=\1\2\0006\1\0\0'\3\4\0B\1\2\0023\2\5\0006\3\6\0\b\3\0\0X\3'Ä9\3\a\0015\5\b\0006\6\t\0009\6\n\0069\6\v\6B\6\1\0A\3\1\2:\4\1\3\a\4\f\0X\4\3Ä\18\4\2\0B\4\1\1X\4\28Ä6\4\r\0009\4\14\4'\6\15\0B\4\2\2\18\a\4\0009\5\16\4'\b\17\0B\5\3\2\18\b\4\0009\6\18\4B\6\2\0014\6\0\0\18\t\5\0009\a\19\5'\n\20\0B\a\3\4X\n\5Ä6\v\21\0009\v\22\v\18\r\6\0\18\14\n\0B\v\3\1E\n\3\2R\n˘=\6\23\0X\3\2Ä\18\3\2\0B\3\1\0014\3\5\0005\4\25\0>\4\1\0035\4\26\0>\4\2\0035\4\27\0>\4\3\0035\4\28\0>\4\4\3=\3\24\0002\0\0ÄK\0\1\0\1\0\3\ticon\tÔÜö \vaction\31call v:lua.TelescopeGrep()\tdesc\"Find word                    \1\0\3\ticon\tÔú° \vaction\21DashboardNewFile\tdesc\"New file                     \1\0\4\ticon\tÔú° \rshortcut\vctrl p\vaction\25Telescope find_files\tdesc\29Find file               \1\0\4\ticon\tÔë§ \rshortcut\n\\ s l\vaction,SessionManager load_current_dir_session\tdesc\30Last Session             \18custom_center\18custom_footer\vinsert\ntable\v[^\r\n]+\vgmatch\nclose\a*a\tread\ffortune\npopen\aio\ttrue\bcwd\tloop\bvim\1\4\0\0\bgit\14rev-parse\26--is-inside-work-tree\26get_os_command_output\bret\0\20telescope.utils\1\18\0\0\17            \17            \25    ‚Üë‚Üë‚Üì‚Üì    \25   ‚Üê‚Üí‚Üê‚ÜíAB   \29   ‚îå‚îÄ‚îÄ‚îÄ‚îÄ‚îê   \23   ‚îÇ    ‚îú‚îê  \27   ‚îÇ‚îå ‚îå ‚îî‚îÇ  \25   ‚îÇ ‚ïò  ‚îî‚îò  \21   ‚îÇ    ‚îÇ   \25   ‚îÇ‚ïô‚îÄ  ‚îÇ   \21   ‚îÇ    ‚îÇ   \27   ‚îî‚îÄ‚îÄ‚îò ‚îÇ   \21     ‚îÇ  ‚îÇ   \21     ‚îÇ  ‚îÇ   \17            \17            \17            \18custom_header\14dashboard\frequire\0\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/dashboard-nvim",
    url = "https://github.com/glepnir/dashboard-nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  indentLine = {
    config = { "\27LJ\2\n|\0\0\2\0\6\0\t6\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\6n\29indentLine_concealcursor\1\3\0\0\14dashboard\vpacker\31indentLine_fileTypeExclude\6g\bvim\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/indentLine",
    url = "https://github.com/Yggdroot/indentLine"
  },
  loupe = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/loupe",
    url = "https://github.com/wincent/loupe"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n\17\0\0\1\0\1\0\2'\0\0\0L\0\2\0\6|\19\0\0\1\0\1\0\2'\0\0\0L\0\2\0\bÔÄÑê\5\1\0\n\0)\0G6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0036\4\0\0'\6\b\0B\4\2\2=\4\t\3=\3\v\0025\3\r\0005\4\f\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0034\4\0\0=\4\19\0035\4\20\0=\4\21\0034\4\3\0005\5\27\0003\6\22\0>\6\1\0055\6\25\0006\a\0\0'\t\23\0B\a\2\0029\a\24\a=\a\26\6=\6\28\5>\5\1\0045\5 \0003\6\29\0>\6\1\0055\6\31\0006\a\0\0'\t\23\0B\a\2\0029\a\30\a=\a\26\6=\6\28\5>\5\2\4=\4!\3=\3\"\0025\3#\0004\4\0\0=\4\14\0034\4\0\0=\4\16\0035\4$\0=\4\18\0035\4%\0=\4\19\0034\4\0\0=\4\21\0034\4\0\0=\4!\3=\3&\0024\3\0\0=\3'\0024\3\0\0=\3(\2B\0\2\1K\0\1\0\15extensions\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\rsections\14lualine_z\1\0\0\1\0\0\bred\0\ncolor\1\0\0\afg\1\0\0\abg\16void_colors\0\14lualine_y\1\2\0\0\rfiletype\14lualine_x\14lualine_c\1\2\0\0\16diagnostics\14lualine_b\1\2\0\0\rfilename\14lualine_a\1\0\0\1\2\0\0\tmode\foptions\1\0\0\ntheme\18lualine_theme\23section_separators\1\0\2\nright\bÓÉÖ\tleft\bÓÉÑ\25component_separators\1\0\0\1\0\2\nright\5\tleft\5\nsetup\flualine\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  neoformat = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/neoformat",
    url = "https://github.com/sbdchd/neoformat"
  },
  ["neovim-session-manager"] = {
    config = { "\27LJ\2\n©\1\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0006\3\0\0'\5\3\0B\3\2\0029\3\4\0039\3\5\3=\3\a\2B\0\2\1K\0\1\0\18autoload_mode\1\0\1\20max_path_length\3\0\rDisabled\17AutoloadMode\27session_manager.config\nsetup\20session_manager\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/neovim-session-manager",
    url = "https://github.com/Shatur/neovim-session-manager"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireí\5\1\0\n\0(\0W6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\14\0005\4\f\0004\5\b\0009\6\3\0009\6\4\0069\6\5\6>\6\1\0059\6\3\0009\6\4\0069\6\6\6>\6\2\0059\6\3\0009\6\4\0069\6\a\6>\6\3\0059\6\3\0009\6\4\0069\6\b\6>\6\4\0059\6\3\0009\6\4\0069\6\t\6>\6\5\0059\6\3\0009\6\4\0069\6\n\6>\6\6\0059\6\3\0009\6\4\0069\6\v\6>\6\a\5=\5\r\4=\4\15\0035\4\17\0003\5\16\0=\5\18\4=\4\19\0035\4\22\0009\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\23\0049\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\24\4=\4\20\0039\4\25\0009\4\26\0049\4\27\0045\6\29\0009\a\25\0009\a\28\aB\a\1\2=\a\30\0069\a\25\0009\a\31\a5\t \0B\a\2\2=\a!\0069\a\25\0009\a\31\a5\t\"\0B\a\2\2=\a#\6B\4\2\2=\4\25\0039\4\3\0009\4$\0044\6\3\0005\a%\0>\a\1\0065\a&\0>\a\2\0064\a\3\0005\b'\0>\b\1\aB\4\3\2=\4$\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\n<Tab>\1\0\1\vselect\2\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\1\0\0\nabort\vinsert\vpreset\fmapping\18documentation\15completion\1\0\0\rbordered\vwindow\fsnippet\vexpand\1\0\0\0\fsorting\1\0\0\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nscore\nexact\voffset\fcompare\vconfig\nsetup\bcmp\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-comment"] = {
    config = { "\27LJ\2\nt\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\17line_mapping\15<leader>cc\21operator_mapping\14<leader>c\nsetup\17nvim_comment\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-comment",
    url = "https://github.com/terrortylor/nvim-comment"
  },
  ["nvim-lint"] = {
    config = { "\27LJ\2\nı\2\0\0\4\0\r\0\0196\0\0\0'\2\1\0B\0\2\0025\1\4\0005\2\3\0=\2\5\1=\1\2\0006\0\0\0'\2\6\0B\0\2\2+\1\2\0=\1\a\0005\1\t\0=\1\b\0006\1\n\0009\1\v\1'\3\f\0B\1\2\1K\0\1\0e\t\t\t\taugroup lint\n\t\t\t\tau InsertLeave <buffer> lua require('lint').try_lint()\n\t\t\t\taugroup END\n\t\t\t\t\bcmd\bvim\1\6\0\0\brun\17--out-format\tjson\r--config<~/workspace/api-v2-backend/.build/scripts/.golangci.yml\targs\17append_fname\30lint.linters.golangcilint\ago\1\0\0\1\2\0\0\17golangcilint\18linters_by_ft\tlint\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-lint",
    url = "https://github.com/mfussenegger/nvim-lint"
  },
  ["nvim-lsp-installer"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-lsp-installer",
    url = "https://github.com/williamboman/nvim-lsp-installer"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\nH\0\0\3\0\4\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rocamllsp\14lspconfig\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\ng\0\0\2\0\6\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\31nvim_treesitter#foldexpr()\rfoldexpr\texpr\15foldmethod\bopt\bvim“\4\1\0\b\0\18\0\0266\0\0\0009\0\1\0009\0\2\0005\2\3\0005\3\6\0006\4\0\0009\4\1\0049\4\4\4'\6\5\0004\a\0\0B\4\3\2=\4\a\0033\4\b\0=\4\t\3B\0\3\0016\0\n\0'\2\v\0B\0\2\0029\0\f\0005\2\14\0005\3\r\0=\3\15\0025\3\16\0=\3\17\2B\0\2\1K\0\1\0\14highlight\1\0\2\venable\2&additional_vim_regex_highlighting\2\21ensure_installed\1\0\0\1&\0\0\tbash\ncmake\fcomment\bcss\15dockerfile\tfish\14gitignore\ago\ngomod\fgraphql\thtml\thttp\15javascript\njsdoc\tjson\njson5\nlatex\blua\tmake\rmarkdown\nocaml\vpython\nregex\truby\trust\tscss\rsolidity\bsql\vsvelte\nswift\ftodotxt\ttoml\btsx\15typescript\bvim\bvue\tyaml\nsetup\28nvim-treesitter.configs\frequire\rcallback\0\ngroup\1\0\0\23TS_FOLD_WORKAROUND\24nvim_create_augroup\1\6\0\0\rBufEnter\vBufAdd\vBufNew\15BufNewFile\16BufWinEnter\24nvim_create_autocmd\bapi\bvim\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["space-nvim"] = {
    after = { "bufferline.nvim" },
    config = { "\27LJ\2\n±\1\0\0\6\0\t\0\0156\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0029\3\3\0009\4\4\0009\5\5\0B\1\4\0016\1\6\0009\1\a\1'\3\b\0B\1\2\1K\0\1\0\21colorscheme void\bcmd\bvim\25terminal_ansi_colors\21highlight_groups\27highlight_group_normal\15space-nvim\tvoid\frequire\0" },
    loaded = true,
    only_config = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/space-nvim",
    url = "https://github.com/Th3Whit3Wolf/space-nvim"
  },
  ["telescope-file-browser.nvim"] = {
    config = { "\27LJ\2\nQ\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\17file_browser\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/opt/telescope-file-browser.nvim",
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    config = { "\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14ui-select\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/opt/telescope-ui-select.nvim",
    url = "https://github.com/nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    after = { "telescope-file-browser.nvim", "telescope-ui-select.nvim" },
    config = { "\27LJ\2\n]\0\0\1\0\1\0\0025\0\0\0L\0\2\0\1\a\0\0\17--no-heading\20--with-filename\18--line-number\r--column\r--hidden\17--smart-case\a\1\0\v\0:\1L6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0029\2\4\0025\4\27\0005\5\17\0005\6\f\0005\a\6\0009\b\5\1=\b\a\a9\b\b\0=\b\t\a9\b\n\0=\b\v\a=\a\r\0065\a\14\0009\b\5\1=\b\15\a=\a\16\6=\6\18\0055\6\19\0=\6\20\0055\6\24\0005\a\21\0005\b\22\0=\b\23\a=\a\25\6=\6\26\5=\5\28\0045\5 \0005\6\30\0005\a\29\0=\a\31\6=\6!\0055\6#\0005\a\"\0=\a$\0063\a%\0=\a&\6=\6'\0055\6-\0005\a,\0005\b*\0009\t(\0009\n)\0 \t\n\t=\t+\b=\b\r\a=\a\18\6=\6.\5=\5/\0045\0054\0004\6\3\0006\a\0\0'\t0\0B\a\2\0029\a1\a5\t3\0005\n2\0=\n\20\tB\a\2\0?\a\0\0=\0065\0055\0066\0005\a7\0=\a\20\6=\0068\5=\0059\4B\2\2\1K\0\1\0\15extensions\17file_browser\1\0\1\20prompt_position\btop\1\0\3\ntheme\rdropdown\vhidden\2\22respect_gitignore\2\14ui-select\1\0\0\1\0\0\1\0\1\20prompt_position\btop\17get_dropdown\21telescope.themes\fpickers\fbuffers\1\0\0\1\0\0\n<c-q>\1\0\0\16move_to_top\18delete_buffer\14live_grep\20additional_args\0\25file_ignore_patterns\1\0\1\17find_command\arg\1\3\0\0\17node_modules\t.git\15find_files\1\0\0\17find_command\1\0\0\1\a\0\0\afd\r--hidden\v--glob\5\v--type\tfile\rdefaults\1\0\0\17path_display\fshorten\1\0\0\fexclude\1\3\0\0\3ˇˇˇˇ\15\3˛ˇˇˇ\15\1\0\1\blen\3\2\18layout_config\1\0\1\20prompt_position\vbottom\rmappings\1\0\1\20layout_strategy\16bottom_pane\6n\n<c-t>\1\0\0\6i\1\0\0\n<c-k>\28move_selection_previous\n<c-j>\24move_selection_next\n<c-d>\1\0\0\22open_with_trouble\nsetup\14telescope trouble.providers.telescope\22telescope.actions\frequire\3ÄÄ¿ô\4\0" },
    loaded = true,
    only_config = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  },
  ["vim-rainbow"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-rainbow",
    url = "https://github.com/frazrepo/vim-rainbow"
  },
  ["vim-sleuth"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-sleuth",
    url = "https://github.com/tpope/vim-sleuth"
  },
  ["vim-solidity"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/opt/vim-solidity",
    url = "https://github.com/tomlion/vim-solidity"
  },
  ["vim-startuptime"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-startuptime",
    url = "https://github.com/dstein64/vim-startuptime"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-tpipeline"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-tpipeline",
    url = "https://github.com/vimpostor/vim-tpipeline"
  },
  ["yajs.vim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/yajs.vim",
    url = "https://github.com/othree/yajs.vim"
  },
  ["zen-mode.nvim"] = {
    config = { "\27LJ\2\nó\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\vwindow\1\0\0\foptions\1\0\2\19relativenumber\1\vnumber\1\1\0\2\vheight\4‹ûäÆ\15®∏ùˇ\3\rbackdrop\3\1\nsetup\rzen-mode\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/zen-mode.nvim",
    url = "https://github.com/folke/zen-mode.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: neovim-session-manager
time([[Config for neovim-session-manager]], true)
try_loadstring("\27LJ\2\n©\1\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0006\3\0\0'\5\3\0B\3\2\0029\3\4\0039\3\5\3=\3\a\2B\0\2\1K\0\1\0\18autoload_mode\1\0\1\20max_path_length\3\0\rDisabled\17AutoloadMode\27session_manager.config\nsetup\20session_manager\frequire\0", "config", "neovim-session-manager")
time([[Config for neovim-session-manager]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rocamllsp\14lspconfig\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: indentLine
time([[Config for indentLine]], true)
try_loadstring("\27LJ\2\n|\0\0\2\0\6\0\t6\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\6n\29indentLine_concealcursor\1\3\0\0\14dashboard\vpacker\31indentLine_fileTypeExclude\6g\bvim\0", "config", "indentLine")
time([[Config for indentLine]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireí\5\1\0\n\0(\0W6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\14\0005\4\f\0004\5\b\0009\6\3\0009\6\4\0069\6\5\6>\6\1\0059\6\3\0009\6\4\0069\6\6\6>\6\2\0059\6\3\0009\6\4\0069\6\a\6>\6\3\0059\6\3\0009\6\4\0069\6\b\6>\6\4\0059\6\3\0009\6\4\0069\6\t\6>\6\5\0059\6\3\0009\6\4\0069\6\n\6>\6\6\0059\6\3\0009\6\4\0069\6\v\6>\6\a\5=\5\r\4=\4\15\0035\4\17\0003\5\16\0=\5\18\4=\4\19\0035\4\22\0009\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\23\0049\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\24\4=\4\20\0039\4\25\0009\4\26\0049\4\27\0045\6\29\0009\a\25\0009\a\28\aB\a\1\2=\a\30\0069\a\25\0009\a\31\a5\t \0B\a\2\2=\a!\0069\a\25\0009\a\31\a5\t\"\0B\a\2\2=\a#\6B\4\2\2=\4\25\0039\4\3\0009\4$\0044\6\3\0005\a%\0>\a\1\0065\a&\0>\a\2\0064\a\3\0005\b'\0>\b\1\aB\4\3\2=\4$\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\n<Tab>\1\0\1\vselect\2\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\1\0\0\nabort\vinsert\vpreset\fmapping\18documentation\15completion\1\0\0\rbordered\vwindow\fsnippet\vexpand\1\0\0\0\fsorting\1\0\0\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nscore\nexact\voffset\fcompare\vconfig\nsetup\bcmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\ng\0\0\2\0\6\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\31nvim_treesitter#foldexpr()\rfoldexpr\texpr\15foldmethod\bopt\bvim“\4\1\0\b\0\18\0\0266\0\0\0009\0\1\0009\0\2\0005\2\3\0005\3\6\0006\4\0\0009\4\1\0049\4\4\4'\6\5\0004\a\0\0B\4\3\2=\4\a\0033\4\b\0=\4\t\3B\0\3\0016\0\n\0'\2\v\0B\0\2\0029\0\f\0005\2\14\0005\3\r\0=\3\15\0025\3\16\0=\3\17\2B\0\2\1K\0\1\0\14highlight\1\0\2\venable\2&additional_vim_regex_highlighting\2\21ensure_installed\1\0\0\1&\0\0\tbash\ncmake\fcomment\bcss\15dockerfile\tfish\14gitignore\ago\ngomod\fgraphql\thtml\thttp\15javascript\njsdoc\tjson\njson5\nlatex\blua\tmake\rmarkdown\nocaml\vpython\nregex\truby\trust\tscss\rsolidity\bsql\vsvelte\nswift\ftodotxt\ttoml\btsx\15typescript\bvim\bvue\tyaml\nsetup\28nvim-treesitter.configs\frequire\rcallback\0\ngroup\1\0\0\23TS_FOLD_WORKAROUND\24nvim_create_augroup\1\6\0\0\rBufEnter\vBufAdd\vBufNew\15BufNewFile\16BufWinEnter\24nvim_create_autocmd\bapi\bvim\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-lint
time([[Config for nvim-lint]], true)
try_loadstring("\27LJ\2\nı\2\0\0\4\0\r\0\0196\0\0\0'\2\1\0B\0\2\0025\1\4\0005\2\3\0=\2\5\1=\1\2\0006\0\0\0'\2\6\0B\0\2\2+\1\2\0=\1\a\0005\1\t\0=\1\b\0006\1\n\0009\1\v\1'\3\f\0B\1\2\1K\0\1\0e\t\t\t\taugroup lint\n\t\t\t\tau InsertLeave <buffer> lua require('lint').try_lint()\n\t\t\t\taugroup END\n\t\t\t\t\bcmd\bvim\1\6\0\0\brun\17--out-format\tjson\r--config<~/workspace/api-v2-backend/.build/scripts/.golangci.yml\targs\17append_fname\30lint.linters.golangcilint\ago\1\0\0\1\2\0\0\17golangcilint\18linters_by_ft\tlint\frequire\0", "config", "nvim-lint")
time([[Config for nvim-lint]], false)
-- Config for: nvim-comment
time([[Config for nvim-comment]], true)
try_loadstring("\27LJ\2\nt\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\17line_mapping\15<leader>cc\21operator_mapping\14<leader>c\nsetup\17nvim_comment\frequire\0", "config", "nvim-comment")
time([[Config for nvim-comment]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n\17\0\0\1\0\1\0\2'\0\0\0L\0\2\0\6|\19\0\0\1\0\1\0\2'\0\0\0L\0\2\0\bÔÄÑê\5\1\0\n\0)\0G6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0036\4\0\0'\6\b\0B\4\2\2=\4\t\3=\3\v\0025\3\r\0005\4\f\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0034\4\0\0=\4\19\0035\4\20\0=\4\21\0034\4\3\0005\5\27\0003\6\22\0>\6\1\0055\6\25\0006\a\0\0'\t\23\0B\a\2\0029\a\24\a=\a\26\6=\6\28\5>\5\1\0045\5 \0003\6\29\0>\6\1\0055\6\31\0006\a\0\0'\t\23\0B\a\2\0029\a\30\a=\a\26\6=\6\28\5>\5\2\4=\4!\3=\3\"\0025\3#\0004\4\0\0=\4\14\0034\4\0\0=\4\16\0035\4$\0=\4\18\0035\4%\0=\4\19\0034\4\0\0=\4\21\0034\4\0\0=\4!\3=\3&\0024\3\0\0=\3'\0024\3\0\0=\3(\2B\0\2\1K\0\1\0\15extensions\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\rsections\14lualine_z\1\0\0\1\0\0\bred\0\ncolor\1\0\0\afg\1\0\0\abg\16void_colors\0\14lualine_y\1\2\0\0\rfiletype\14lualine_x\14lualine_c\1\2\0\0\16diagnostics\14lualine_b\1\2\0\0\rfilename\14lualine_a\1\0\0\1\2\0\0\tmode\foptions\1\0\0\ntheme\18lualine_theme\23section_separators\1\0\2\nright\bÓÉÖ\tleft\bÓÉÑ\25component_separators\1\0\0\1\0\2\nright\5\tleft\5\nsetup\flualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: dashboard-nvim
time([[Config for dashboard-nvim]], true)
try_loadstring("\27LJ\2\nŸ\1\0\0\a\2\6\2\0205\0\0\0-\1\0\0009\1\1\1\18\3\0\0B\1\2\2\21\2\1\0\t\2\0\0X\2\4Ä-\2\1\0005\3\3\0=\3\2\2X\2\aÄ-\2\1\0005\3\4\0006\4\5\0\18\6\1\0B\4\2\0?\4\1\0=\3\2\2K\0\1\0\1¿\0¿\vunpack\1\5\0\0\5\5\15Git status\5\1\6\0\0\5\5\15Git status\5\21No files changed\18custom_footer\26get_os_command_output\1\6\0\0\bgit\vstatus\a-s\a--\6.\0\vÄÄ¿ô\4˘\b\1\0\15\0\29\1A6\0\0\0'\2\1\0B\0\2\0025\1\3\0=\1\2\0006\1\0\0'\3\4\0B\1\2\0023\2\5\0006\3\6\0\b\3\0\0X\3'Ä9\3\a\0015\5\b\0006\6\t\0009\6\n\0069\6\v\6B\6\1\0A\3\1\2:\4\1\3\a\4\f\0X\4\3Ä\18\4\2\0B\4\1\1X\4\28Ä6\4\r\0009\4\14\4'\6\15\0B\4\2\2\18\a\4\0009\5\16\4'\b\17\0B\5\3\2\18\b\4\0009\6\18\4B\6\2\0014\6\0\0\18\t\5\0009\a\19\5'\n\20\0B\a\3\4X\n\5Ä6\v\21\0009\v\22\v\18\r\6\0\18\14\n\0B\v\3\1E\n\3\2R\n˘=\6\23\0X\3\2Ä\18\3\2\0B\3\1\0014\3\5\0005\4\25\0>\4\1\0035\4\26\0>\4\2\0035\4\27\0>\4\3\0035\4\28\0>\4\4\3=\3\24\0002\0\0ÄK\0\1\0\1\0\3\ticon\tÔÜö \vaction\31call v:lua.TelescopeGrep()\tdesc\"Find word                    \1\0\3\ticon\tÔú° \vaction\21DashboardNewFile\tdesc\"New file                     \1\0\4\ticon\tÔú° \rshortcut\vctrl p\vaction\25Telescope find_files\tdesc\29Find file               \1\0\4\ticon\tÔë§ \rshortcut\n\\ s l\vaction,SessionManager load_current_dir_session\tdesc\30Last Session             \18custom_center\18custom_footer\vinsert\ntable\v[^\r\n]+\vgmatch\nclose\a*a\tread\ffortune\npopen\aio\ttrue\bcwd\tloop\bvim\1\4\0\0\bgit\14rev-parse\26--is-inside-work-tree\26get_os_command_output\bret\0\20telescope.utils\1\18\0\0\17            \17            \25    ‚Üë‚Üë‚Üì‚Üì    \25   ‚Üê‚Üí‚Üê‚ÜíAB   \29   ‚îå‚îÄ‚îÄ‚îÄ‚îÄ‚îê   \23   ‚îÇ    ‚îú‚îê  \27   ‚îÇ‚îå ‚îå ‚îî‚îÇ  \25   ‚îÇ ‚ïò  ‚îî‚îò  \21   ‚îÇ    ‚îÇ   \25   ‚îÇ‚ïô‚îÄ  ‚îÇ   \21   ‚îÇ    ‚îÇ   \27   ‚îî‚îÄ‚îÄ‚îò ‚îÇ   \21     ‚îÇ  ‚îÇ   \21     ‚îÇ  ‚îÇ   \17            \17            \17            \18custom_header\14dashboard\frequire\0\0", "config", "dashboard-nvim")
time([[Config for dashboard-nvim]], false)
-- Config for: space-nvim
time([[Config for space-nvim]], true)
try_loadstring("\27LJ\2\n±\1\0\0\6\0\t\0\0156\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0029\3\3\0009\4\4\0009\5\5\0B\1\4\0016\1\6\0009\1\a\1'\3\b\0B\1\2\1K\0\1\0\21colorscheme void\bcmd\bvim\25terminal_ansi_colors\21highlight_groups\27highlight_group_normal\15space-nvim\tvoid\frequire\0", "config", "space-nvim")
time([[Config for space-nvim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\n]\0\0\1\0\1\0\0025\0\0\0L\0\2\0\1\a\0\0\17--no-heading\20--with-filename\18--line-number\r--column\r--hidden\17--smart-case\a\1\0\v\0:\1L6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0029\2\4\0025\4\27\0005\5\17\0005\6\f\0005\a\6\0009\b\5\1=\b\a\a9\b\b\0=\b\t\a9\b\n\0=\b\v\a=\a\r\0065\a\14\0009\b\5\1=\b\15\a=\a\16\6=\6\18\0055\6\19\0=\6\20\0055\6\24\0005\a\21\0005\b\22\0=\b\23\a=\a\25\6=\6\26\5=\5\28\0045\5 \0005\6\30\0005\a\29\0=\a\31\6=\6!\0055\6#\0005\a\"\0=\a$\0063\a%\0=\a&\6=\6'\0055\6-\0005\a,\0005\b*\0009\t(\0009\n)\0 \t\n\t=\t+\b=\b\r\a=\a\18\6=\6.\5=\5/\0045\0054\0004\6\3\0006\a\0\0'\t0\0B\a\2\0029\a1\a5\t3\0005\n2\0=\n\20\tB\a\2\0?\a\0\0=\0065\0055\0066\0005\a7\0=\a\20\6=\0068\5=\0059\4B\2\2\1K\0\1\0\15extensions\17file_browser\1\0\1\20prompt_position\btop\1\0\3\ntheme\rdropdown\vhidden\2\22respect_gitignore\2\14ui-select\1\0\0\1\0\0\1\0\1\20prompt_position\btop\17get_dropdown\21telescope.themes\fpickers\fbuffers\1\0\0\1\0\0\n<c-q>\1\0\0\16move_to_top\18delete_buffer\14live_grep\20additional_args\0\25file_ignore_patterns\1\0\1\17find_command\arg\1\3\0\0\17node_modules\t.git\15find_files\1\0\0\17find_command\1\0\0\1\a\0\0\afd\r--hidden\v--glob\5\v--type\tfile\rdefaults\1\0\0\17path_display\fshorten\1\0\0\fexclude\1\3\0\0\3ˇˇˇˇ\15\3˛ˇˇˇ\15\1\0\1\blen\3\2\18layout_config\1\0\1\20prompt_position\vbottom\rmappings\1\0\1\20layout_strategy\16bottom_pane\6n\n<c-t>\1\0\0\6i\1\0\0\n<c-k>\28move_selection_previous\n<c-j>\24move_selection_next\n<c-d>\1\0\0\22open_with_trouble\nsetup\14telescope trouble.providers.telescope\22telescope.actions\frequire\3ÄÄ¿ô\4\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: zen-mode.nvim
time([[Config for zen-mode.nvim]], true)
try_loadstring("\27LJ\2\nó\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\vwindow\1\0\0\foptions\1\0\2\19relativenumber\1\vnumber\1\1\0\2\vheight\4‹ûäÆ\15®∏ùˇ\3\rbackdrop\3\1\nsetup\rzen-mode\frequire\0", "config", "zen-mode.nvim")
time([[Config for zen-mode.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd telescope-ui-select.nvim ]]

-- Config for: telescope-ui-select.nvim
try_loadstring("\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14ui-select\19load_extension\14telescope\frequire\0", "config", "telescope-ui-select.nvim")

vim.cmd [[ packadd telescope-file-browser.nvim ]]

-- Config for: telescope-file-browser.nvim
try_loadstring("\27LJ\2\nQ\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\17file_browser\19load_extension\14telescope\frequire\0", "config", "telescope-file-browser.nvim")

vim.cmd [[ packadd bufferline.nvim ]]

-- Config for: bufferline.nvim
try_loadstring("\27LJ\2\nO\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\fbuffers\nsetup\26cmds/setup_bufferline\frequire\0", "config", "bufferline.nvim")

time([[Sequenced loading]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType solidity ++once lua require("packer.load")({'vim-solidity'}, { ft = "solidity" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /Users/kyle/.local/share/nvim/site/pack/packer/opt/vim-solidity/ftdetect/solidity.vim]], true)
vim.cmd [[source /Users/kyle/.local/share/nvim/site/pack/packer/opt/vim-solidity/ftdetect/solidity.vim]]
time([[Sourcing ftdetect script at: /Users/kyle/.local/share/nvim/site/pack/packer/opt/vim-solidity/ftdetect/solidity.vim]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
