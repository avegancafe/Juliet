-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
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

  _G._packer = _G._packer or {}
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
  local success, result = pcall(loadstring(s))
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
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/LuaSnip"
  },
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\nO\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\fbuffers\nsetup\26cmds/setup_bufferline\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/bufferline.nvim"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp"
  },
  ["committia.vim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/committia.vim"
  },
  ["dashboard-nvim"] = {
    config = { "\27LJ\2\nÙ\1\0\0\a\2\6\2\0205\0\0\0-\1\0\0009\1\1\1\18\3\0\0B\1\2\2\21\2\1\0\t\2\0\0X\2\4-\2\1\0005\3\3\0=\3\2\2X\2\a-\2\1\0005\3\4\0006\4\5\0\18\6\1\0B\4\2\0?\4\1\0=\3\2\2K\0\1\0\1À\0À\vunpack\1\5\0\0\5\5\15Git status\5\1\6\0\0\5\5\15Git status\5\21No files changed\18custom_footer\26get_os_command_output\1\6\0\0\bgit\vstatus\a-s\a--\6.\0\vÀ\4Ì\t\1\0\18\0\31\1J6\0\0\0'\2\1\0B\0\2\0025\1\3\0=\1\2\0006\1\0\0'\3\4\0B\1\2\0026\2\5\0009\2\6\0029\2\a\0029\3\b\0015\5\t\0006\6\5\0009\6\n\0069\6\v\6B\6\1\0A\3\1\0033\5\f\0\b\4\0\0X\6'9\6\b\0015\b\r\0006\t\5\0009\t\n\t9\t\v\tB\t\1\0A\6\1\2:\a\1\6\a\a\14\0X\a\3\18\a\5\0B\a\1\1X\a\286\a\15\0009\a\16\a'\t\17\0B\a\2\2\18\n\a\0009\b\18\a'\v\19\0B\b\3\2\18\v\a\0009\t\20\aB\t\2\0014\t\0\0\18\f\b\0009\n\21\b'\r\22\0B\n\3\4X\r\56\14\23\0009\14\24\14\18\16\t\0\18\17\r\0B\14\3\1E\r\3\2R\rù=\t\25\0X\6\2\18\6\5\0B\6\1\0014\6\5\0005\a\27\0>\a\1\0065\a\28\0>\a\2\0065\a\29\0>\a\3\0065\a\30\0>\a\4\6=\6\26\0002\0\0K\0\1\0\1\0\3\vaction\31call v:lua.TelescopeGrep()\tdesc\"Find word                    \ticon\tï \1\0\3\vaction\21DashboardNewFile\tdesc\"New file                     \ticon\tï¡ \1\0\4\vaction\25Telescope find_files\tdesc\29Find file               \ticon\tï¡ \rshortcut\vctrl p\1\0\4\vaction,SessionManager load_current_dir_session\tdesc\30Last Session             \ticon\tï¤ \rshortcut\n\\ s l\18custom_center\18custom_footer\vinsert\ntable\v[^\r\n]+\vgmatch\nclose\a*a\tread\ffortune\npopen\aio\ttrue\1\4\0\0\bgit\14rev-parse\26--is-inside-work-tree\0\bcwd\tloop\1\4\0\0\bgit\14rev-parse\20--show-toplevel\26get_os_command_output\17nvim_set_var\bapi\bvim\20telescope.utils\1\18\0\0\17            \17            \25    ââââ    \25   ââââAB   \29   ââââââ   \23   â    ââ  \27   ââ â ââ  \25   â â  ââ  \21   â    â   \25   âââ  â   \21   â    â   \27   ââââ â   \21     â  â   \21     â  â   \17            \17            \17            \18custom_header\14dashboard\frequire\0\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/dashboard-nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  indentLine = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/indentLine"
  },
  loupe = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/loupe"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n\17\0\0\1\0\1\0\2'\0\0\0L\0\2\0\6|\19\0\0\1\0\1\0\2'\0\0\0L\0\2\0\bï\5\1\0\n\0)\0G6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0036\4\0\0'\6\b\0B\4\2\2=\4\t\3=\3\v\0025\3\r\0005\4\f\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0034\4\0\0=\4\19\0035\4\20\0=\4\21\0034\4\3\0005\5\27\0003\6\22\0>\6\1\0055\6\25\0006\a\0\0'\t\23\0B\a\2\0029\a\24\a=\a\26\6=\6\28\5>\5\1\0045\5 \0003\6\29\0>\6\1\0055\6\31\0006\a\0\0'\t\23\0B\a\2\0029\a\30\a=\a\26\6=\6\28\5>\5\2\4=\4!\3=\3\"\0025\3#\0004\4\0\0=\4\14\0034\4\0\0=\4\16\0035\4$\0=\4\18\0035\4%\0=\4\19\0034\4\0\0=\4\21\0034\4\0\0=\4!\3=\3&\0024\3\0\0=\3'\0024\3\0\0=\3(\2B\0\2\1K\0\1\0\15extensions\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\rsections\14lualine_z\1\0\0\1\0\0\bred\0\ncolor\1\0\0\afg\1\0\0\abg\16void_colors\0\14lualine_y\1\2\0\0\rfiletype\14lualine_x\14lualine_c\1\2\0\0\16diagnostics\14lualine_b\1\2\0\0\rfilename\14lualine_a\1\0\0\1\2\0\0\tmode\foptions\1\0\0\ntheme\18lualine_theme\23section_separators\1\0\2\tleft\bî\nright\bî\25component_separators\1\0\0\1\0\2\tleft\5\nright\5\nsetup\flualine\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/lualine.nvim"
  },
  neoformat = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/neoformat"
  },
  neorg = {
    config = { "\27LJ\2\n×\2\0\0\a\0\17\0\0236\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\15\0005\3\3\0004\4\0\0=\4\4\0034\4\0\0=\4\5\0035\4\a\0005\5\6\0=\5\b\4=\4\t\0035\4\r\0005\5\v\0005\6\n\0=\6\f\5=\5\b\4=\4\14\3=\3\16\2B\0\2\1K\0\1\0\tload\1\0\0\21core.norg.dirman\1\0\0\15workspaces\1\0\0\1\0\3\rfrontend ~/workspace/api-v2-frontend\nnotes\22~/workspace/notes\fbackend\31~/workspace/api-v2-backend\19core.presenter\vconfig\1\0\0\1\0\1\rzen_mode\rzen-mode\24core.norg.concealer\18core.defaults\1\0\0\nsetup\nneorg\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/neorg"
  },
  neoterm = {
    config = { "\27LJ\2\n1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\18syntax enable\bcmd\bvim\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/neoterm"
  },
  ["neovim-session-manager"] = {
    config = { "\27LJ\2\n©\1\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0006\3\0\0'\5\3\0B\3\2\0029\3\4\0039\3\5\3=\3\a\2B\0\2\1K\0\1\0\18autoload_mode\1\0\1\20max_path_length\3\0\rDisabled\17AutoloadMode\27session_manager.config\nsetup\20session_manager\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/neovim-session-manager"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireÐ\5\1\0\n\0+\0`6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\14\0005\4\f\0004\5\b\0009\6\3\0009\6\4\0069\6\5\6>\6\1\0059\6\3\0009\6\4\0069\6\6\6>\6\2\0059\6\3\0009\6\4\0069\6\a\6>\6\3\0059\6\3\0009\6\4\0069\6\b\6>\6\4\0059\6\3\0009\6\4\0069\6\t\6>\6\5\0059\6\3\0009\6\4\0069\6\n\6>\6\6\0059\6\3\0009\6\4\0069\6\v\6>\6\a\5=\5\r\4=\4\15\0035\4\17\0003\5\16\0=\5\18\4=\4\19\0035\4\22\0009\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\23\0049\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\24\4=\4\20\0039\4\25\0009\4\26\0049\4\27\0045\6\29\0009\a\25\0009\a\28\a)\tüÿB\a\2\2=\a\30\0069\a\25\0009\a\28\a)\t\4\0B\a\2\2=\a\31\0069\a\25\0009\a \aB\a\1\2=\a!\0069\a\25\0009\a\"\aB\a\1\2=\a#\0069\a\25\0009\a$\a5\t%\0B\a\2\2=\a&\6B\4\2\2=\4\25\0039\4\3\0009\4'\0044\6\3\0005\a(\0>\a\1\0065\a)\0>\a\2\0064\a\3\0005\b*\0>\b\1\aB\4\3\2=\4'\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\nabort\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\0\16scroll_docs\vinsert\vpreset\fmapping\18documentation\15completion\1\0\0\rbordered\vwindow\fsnippet\vexpand\1\0\0\0\fsorting\1\0\0\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nscore\nexact\voffset\fcompare\vconfig\nsetup\bcmp\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-cmp"
  },
  ["nvim-comment"] = {
    config = { "\27LJ\2\nt\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\17line_mapping\15<leader>cc\21operator_mapping\14<leader>c\nsetup\17nvim_comment\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-comment"
  },
  ["nvim-lint"] = {
    config = { "\27LJ\2\nù\2\0\0\4\0\r\0\0196\0\0\0'\2\1\0B\0\2\0025\1\4\0005\2\3\0=\2\5\1=\1\2\0006\0\0\0'\2\6\0B\0\2\2+\1\2\0=\1\a\0005\1\t\0=\1\b\0006\1\n\0009\1\v\1'\3\f\0B\1\2\1K\0\1\0i\t\t\t\t\taugroup lint\n\t\t\t\t\t\tau InsertLeave <buffer> lua require('lint').try_lint()\n\t\t\t\t\taugroup END\n\t\t\t\t\bcmd\bvim\1\6\0\0\brun\17--out-format\tjson\r--config<~/workspace/api-v2-backend/.build/scripts/.golangci.yml\targs\17append_fname\30lint.linters.golangcilint\ago\1\0\0\1\2\0\0\17golangcilint\18linters_by_ft\tlint\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-lint"
  },
  ["nvim-lsp-installer"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-lsp-installer"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\nH\0\0\3\0\4\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rocamllsp\14lspconfig\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n\4\0\0\5\0\20\0\0286\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0025\1\a\0005\2\4\0005\3\5\0=\3\6\2=\2\b\1=\1\3\0005\1\f\0005\2\n\0005\3\v\0=\3\6\2=\2\b\1=\1\t\0006\1\0\0'\3\r\0B\1\2\0029\1\14\0015\3\15\0005\4\16\0=\4\17\0035\4\18\0=\4\19\3B\1\2\1K\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\1\venable\2\19ignore_install\1\2\0\0\vphpdoc\1\0\1\21ensure_installed\ball\nsetup\28nvim-treesitter.configs\1\0\0\1\2\0\0\17src/parser.c\1\0\2\vbranch\tmain\burl9https://github.com/nvim-neorg/tree-sitter-norg-table\15norg_table\17install_info\1\0\0\nfiles\1\2\0\0\17src/parser.c\1\0\2\vbranch\tmain\burl8https://github.com/nvim-neorg/tree-sitter-norg-meta\14norg_meta\23get_parser_configs\28nvim-treesitter.parsers\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["space-nvim"] = {
    config = { "\27LJ\2\nÁ\1\0\0\5\0\t\0\0196\0\0\0'\2\1\0B\0\2\0027\0\1\0006\0\0\0'\2\2\0B\0\2\0026\2\1\0009\2\3\0026\3\1\0009\3\4\0036\4\1\0009\4\5\4B\0\4\0016\0\6\0009\0\a\0'\2\b\0B\0\2\1K\0\1\0\21colorscheme void\bcmd\bvim\25terminal_ansi_colors\21highlight_groups\27highlight_group_normal\15space-nvim\tvoid\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/space-nvim"
  },
  ["telescope-file-browser.nvim"] = {
    config = { "\27LJ\2\nQ\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\17file_browser\19load_extension\14telescope\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/telescope-file-browser.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    config = { "\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14ui-select\19load_extension\14telescope\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\nÍ\5\0\0\v\0,\1>6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0029\2\4\0025\4\23\0005\5\r\0005\6\b\0005\a\6\0009\b\5\1=\b\a\a=\a\t\0065\a\n\0009\b\5\1=\b\v\a=\a\f\6=\6\14\0055\6\15\0=\6\16\0055\6\20\0005\a\17\0005\b\18\0=\b\19\a=\a\21\6=\6\22\5=\5\24\0045\5\31\0005\6\30\0005\a\29\0005\b\27\0009\t\25\0009\n\26\0 \t\n\t=\t\28\b=\b\t\a=\a\14\6=\6 \5=\5!\0045\5&\0004\6\3\0006\a\0\0'\t\"\0B\a\2\0029\a#\a5\t%\0005\n$\0=\n\16\tB\a\2\0?\a\0\0=\6'\0055\6(\0005\a)\0=\a\16\6=\6*\5=\5+\4B\2\2\1K\0\1\0\15extensions\17file_browser\1\0\1\20prompt_position\btop\1\0\1\ntheme\rdropdown\14ui-select\1\0\0\1\0\0\1\0\1\20prompt_position\btop\17get_dropdown\21telescope.themes\fpickers\fbuffers\1\0\0\1\0\0\1\0\0\n<c-q>\1\0\0\16move_to_top\18delete_buffer\rdefaults\1\0\0\17path_display\fshorten\1\0\0\fexclude\1\3\0\0\3ÿÿÿÿ\15\3þÿÿÿ\15\1\0\1\blen\3\2\18layout_config\1\0\1\20prompt_position\vbottom\rmappings\1\0\1\20layout_strategy\16bottom_pane\6n\n<c-t>\1\0\0\6i\1\0\0\n<c-d>\1\0\0\22open_with_trouble\nsetup\14telescope trouble.providers.telescope\22telescope.actions\frequire\3À\4\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/trouble.nvim"
  },
  ["vim-fish"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-fish"
  },
  ["vim-jsx-pretty"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-jsx-pretty"
  },
  ["vim-rainbow"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-rainbow"
  },
  ["vim-sleuth"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-sleuth"
  },
  ["vim-solidity"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-solidity"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["yajs.vim"] = {
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/yajs.vim"
  },
  ["zen-mode.nvim"] = {
    config = { "\27LJ\2\n\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\vwindow\1\0\0\foptions\1\0\2\19relativenumber\1\vnumber\1\1\0\2\vheight\4Ü®\15¨¸ÿ\3\rbackdrop\3\1\nsetup\rzen-mode\frequire\0" },
    loaded = true,
    path = "/Users/kyle/.local/share/nvim/site/pack/packer/start/zen-mode.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: space-nvim
time([[Config for space-nvim]], true)
try_loadstring("\27LJ\2\nÁ\1\0\0\5\0\t\0\0196\0\0\0'\2\1\0B\0\2\0027\0\1\0006\0\0\0'\2\2\0B\0\2\0026\2\1\0009\2\3\0026\3\1\0009\3\4\0036\4\1\0009\4\5\4B\0\4\0016\0\6\0009\0\a\0'\2\b\0B\0\2\1K\0\1\0\21colorscheme void\bcmd\bvim\25terminal_ansi_colors\21highlight_groups\27highlight_group_normal\15space-nvim\tvoid\frequire\0", "config", "space-nvim")
time([[Config for space-nvim]], false)
-- Config for: neoterm
time([[Config for neoterm]], true)
try_loadstring("\27LJ\2\n1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\18syntax enable\bcmd\bvim\0", "config", "neoterm")
time([[Config for neoterm]], false)
-- Config for: zen-mode.nvim
time([[Config for zen-mode.nvim]], true)
try_loadstring("\27LJ\2\n\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\vwindow\1\0\0\foptions\1\0\2\19relativenumber\1\vnumber\1\1\0\2\vheight\4Ü®\15¨¸ÿ\3\rbackdrop\3\1\nsetup\rzen-mode\frequire\0", "config", "zen-mode.nvim")
time([[Config for zen-mode.nvim]], false)
-- Config for: neovim-session-manager
time([[Config for neovim-session-manager]], true)
try_loadstring("\27LJ\2\n©\1\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0006\3\0\0'\5\3\0B\3\2\0029\3\4\0039\3\5\3=\3\a\2B\0\2\1K\0\1\0\18autoload_mode\1\0\1\20max_path_length\3\0\rDisabled\17AutoloadMode\27session_manager.config\nsetup\20session_manager\frequire\0", "config", "neovim-session-manager")
time([[Config for neovim-session-manager]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireÐ\5\1\0\n\0+\0`6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\14\0005\4\f\0004\5\b\0009\6\3\0009\6\4\0069\6\5\6>\6\1\0059\6\3\0009\6\4\0069\6\6\6>\6\2\0059\6\3\0009\6\4\0069\6\a\6>\6\3\0059\6\3\0009\6\4\0069\6\b\6>\6\4\0059\6\3\0009\6\4\0069\6\t\6>\6\5\0059\6\3\0009\6\4\0069\6\n\6>\6\6\0059\6\3\0009\6\4\0069\6\v\6>\6\a\5=\5\r\4=\4\15\0035\4\17\0003\5\16\0=\5\18\4=\4\19\0035\4\22\0009\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\23\0049\5\3\0009\5\20\0059\5\21\5B\5\1\2=\5\24\4=\4\20\0039\4\25\0009\4\26\0049\4\27\0045\6\29\0009\a\25\0009\a\28\a)\tüÿB\a\2\2=\a\30\0069\a\25\0009\a\28\a)\t\4\0B\a\2\2=\a\31\0069\a\25\0009\a \aB\a\1\2=\a!\0069\a\25\0009\a\"\aB\a\1\2=\a#\0069\a\25\0009\a$\a5\t%\0B\a\2\2=\a&\6B\4\2\2=\4\25\0039\4\3\0009\4'\0044\6\3\0005\a(\0>\a\1\0065\a)\0>\a\2\0064\a\3\0005\b*\0>\b\1\aB\4\3\2=\4'\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\nabort\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\0\16scroll_docs\vinsert\vpreset\fmapping\18documentation\15completion\1\0\0\rbordered\vwindow\fsnippet\vexpand\1\0\0\0\fsorting\1\0\0\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nscore\nexact\voffset\fcompare\vconfig\nsetup\bcmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: nvim-comment
time([[Config for nvim-comment]], true)
try_loadstring("\27LJ\2\nt\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\2\17line_mapping\15<leader>cc\21operator_mapping\14<leader>c\nsetup\17nvim_comment\frequire\0", "config", "nvim-comment")
time([[Config for nvim-comment]], false)
-- Config for: nvim-lint
time([[Config for nvim-lint]], true)
try_loadstring("\27LJ\2\nù\2\0\0\4\0\r\0\0196\0\0\0'\2\1\0B\0\2\0025\1\4\0005\2\3\0=\2\5\1=\1\2\0006\0\0\0'\2\6\0B\0\2\2+\1\2\0=\1\a\0005\1\t\0=\1\b\0006\1\n\0009\1\v\1'\3\f\0B\1\2\1K\0\1\0i\t\t\t\t\taugroup lint\n\t\t\t\t\t\tau InsertLeave <buffer> lua require('lint').try_lint()\n\t\t\t\t\taugroup END\n\t\t\t\t\bcmd\bvim\1\6\0\0\brun\17--out-format\tjson\r--config<~/workspace/api-v2-backend/.build/scripts/.golangci.yml\targs\17append_fname\30lint.linters.golangcilint\ago\1\0\0\1\2\0\0\17golangcilint\18linters_by_ft\tlint\frequire\0", "config", "nvim-lint")
time([[Config for nvim-lint]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rocamllsp\14lspconfig\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: neorg
time([[Config for neorg]], true)
try_loadstring("\27LJ\2\n×\2\0\0\a\0\17\0\0236\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\15\0005\3\3\0004\4\0\0=\4\4\0034\4\0\0=\4\5\0035\4\a\0005\5\6\0=\5\b\4=\4\t\0035\4\r\0005\5\v\0005\6\n\0=\6\f\5=\5\b\4=\4\14\3=\3\16\2B\0\2\1K\0\1\0\tload\1\0\0\21core.norg.dirman\1\0\0\15workspaces\1\0\0\1\0\3\rfrontend ~/workspace/api-v2-frontend\nnotes\22~/workspace/notes\fbackend\31~/workspace/api-v2-backend\19core.presenter\vconfig\1\0\0\1\0\1\rzen_mode\rzen-mode\24core.norg.concealer\18core.defaults\1\0\0\nsetup\nneorg\frequire\0", "config", "neorg")
time([[Config for neorg]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n\4\0\0\5\0\20\0\0286\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0025\1\a\0005\2\4\0005\3\5\0=\3\6\2=\2\b\1=\1\3\0005\1\f\0005\2\n\0005\3\v\0=\3\6\2=\2\b\1=\1\t\0006\1\0\0'\3\r\0B\1\2\0029\1\14\0015\3\15\0005\4\16\0=\4\17\0035\4\18\0=\4\19\3B\1\2\1K\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\1\venable\2\19ignore_install\1\2\0\0\vphpdoc\1\0\1\21ensure_installed\ball\nsetup\28nvim-treesitter.configs\1\0\0\1\2\0\0\17src/parser.c\1\0\2\vbranch\tmain\burl9https://github.com/nvim-neorg/tree-sitter-norg-table\15norg_table\17install_info\1\0\0\nfiles\1\2\0\0\17src/parser.c\1\0\2\vbranch\tmain\burl8https://github.com/nvim-neorg/tree-sitter-norg-meta\14norg_meta\23get_parser_configs\28nvim-treesitter.parsers\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n\17\0\0\1\0\1\0\2'\0\0\0L\0\2\0\6|\19\0\0\1\0\1\0\2'\0\0\0L\0\2\0\bï\5\1\0\n\0)\0G6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0036\4\0\0'\6\b\0B\4\2\2=\4\t\3=\3\v\0025\3\r\0005\4\f\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0034\4\0\0=\4\19\0035\4\20\0=\4\21\0034\4\3\0005\5\27\0003\6\22\0>\6\1\0055\6\25\0006\a\0\0'\t\23\0B\a\2\0029\a\24\a=\a\26\6=\6\28\5>\5\1\0045\5 \0003\6\29\0>\6\1\0055\6\31\0006\a\0\0'\t\23\0B\a\2\0029\a\30\a=\a\26\6=\6\28\5>\5\2\4=\4!\3=\3\"\0025\3#\0004\4\0\0=\4\14\0034\4\0\0=\4\16\0035\4$\0=\4\18\0035\4%\0=\4\19\0034\4\0\0=\4\21\0034\4\0\0=\4!\3=\3&\0024\3\0\0=\3'\0024\3\0\0=\3(\2B\0\2\1K\0\1\0\15extensions\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\rsections\14lualine_z\1\0\0\1\0\0\bred\0\ncolor\1\0\0\afg\1\0\0\abg\16void_colors\0\14lualine_y\1\2\0\0\rfiletype\14lualine_x\14lualine_c\1\2\0\0\16diagnostics\14lualine_b\1\2\0\0\rfilename\14lualine_a\1\0\0\1\2\0\0\tmode\foptions\1\0\0\ntheme\18lualine_theme\23section_separators\1\0\2\tleft\bî\nright\bî\25component_separators\1\0\0\1\0\2\tleft\5\nright\5\nsetup\flualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: dashboard-nvim
time([[Config for dashboard-nvim]], true)
try_loadstring("\27LJ\2\nÙ\1\0\0\a\2\6\2\0205\0\0\0-\1\0\0009\1\1\1\18\3\0\0B\1\2\2\21\2\1\0\t\2\0\0X\2\4-\2\1\0005\3\3\0=\3\2\2X\2\a-\2\1\0005\3\4\0006\4\5\0\18\6\1\0B\4\2\0?\4\1\0=\3\2\2K\0\1\0\1À\0À\vunpack\1\5\0\0\5\5\15Git status\5\1\6\0\0\5\5\15Git status\5\21No files changed\18custom_footer\26get_os_command_output\1\6\0\0\bgit\vstatus\a-s\a--\6.\0\vÀ\4Ì\t\1\0\18\0\31\1J6\0\0\0'\2\1\0B\0\2\0025\1\3\0=\1\2\0006\1\0\0'\3\4\0B\1\2\0026\2\5\0009\2\6\0029\2\a\0029\3\b\0015\5\t\0006\6\5\0009\6\n\0069\6\v\6B\6\1\0A\3\1\0033\5\f\0\b\4\0\0X\6'9\6\b\0015\b\r\0006\t\5\0009\t\n\t9\t\v\tB\t\1\0A\6\1\2:\a\1\6\a\a\14\0X\a\3\18\a\5\0B\a\1\1X\a\286\a\15\0009\a\16\a'\t\17\0B\a\2\2\18\n\a\0009\b\18\a'\v\19\0B\b\3\2\18\v\a\0009\t\20\aB\t\2\0014\t\0\0\18\f\b\0009\n\21\b'\r\22\0B\n\3\4X\r\56\14\23\0009\14\24\14\18\16\t\0\18\17\r\0B\14\3\1E\r\3\2R\rù=\t\25\0X\6\2\18\6\5\0B\6\1\0014\6\5\0005\a\27\0>\a\1\0065\a\28\0>\a\2\0065\a\29\0>\a\3\0065\a\30\0>\a\4\6=\6\26\0002\0\0K\0\1\0\1\0\3\vaction\31call v:lua.TelescopeGrep()\tdesc\"Find word                    \ticon\tï \1\0\3\vaction\21DashboardNewFile\tdesc\"New file                     \ticon\tï¡ \1\0\4\vaction\25Telescope find_files\tdesc\29Find file               \ticon\tï¡ \rshortcut\vctrl p\1\0\4\vaction,SessionManager load_current_dir_session\tdesc\30Last Session             \ticon\tï¤ \rshortcut\n\\ s l\18custom_center\18custom_footer\vinsert\ntable\v[^\r\n]+\vgmatch\nclose\a*a\tread\ffortune\npopen\aio\ttrue\1\4\0\0\bgit\14rev-parse\26--is-inside-work-tree\0\bcwd\tloop\1\4\0\0\bgit\14rev-parse\20--show-toplevel\26get_os_command_output\17nvim_set_var\bapi\bvim\20telescope.utils\1\18\0\0\17            \17            \25    ââââ    \25   ââââAB   \29   ââââââ   \23   â    ââ  \27   ââ â ââ  \25   â â  ââ  \21   â    â   \25   âââ  â   \21   â    â   \27   ââââ â   \21     â  â   \21     â  â   \17            \17            \17            \18custom_header\14dashboard\frequire\0\0", "config", "dashboard-nvim")
time([[Config for dashboard-nvim]], false)
-- Config for: telescope-file-browser.nvim
time([[Config for telescope-file-browser.nvim]], true)
try_loadstring("\27LJ\2\nQ\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\17file_browser\19load_extension\14telescope\frequire\0", "config", "telescope-file-browser.nvim")
time([[Config for telescope-file-browser.nvim]], false)
-- Config for: bufferline.nvim
time([[Config for bufferline.nvim]], true)
try_loadstring("\27LJ\2\nO\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\fbuffers\nsetup\26cmds/setup_bufferline\frequire\0", "config", "bufferline.nvim")
time([[Config for bufferline.nvim]], false)
-- Config for: telescope-ui-select.nvim
time([[Config for telescope-ui-select.nvim]], true)
try_loadstring("\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14ui-select\19load_extension\14telescope\frequire\0", "config", "telescope-ui-select.nvim")
time([[Config for telescope-ui-select.nvim]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\nÍ\5\0\0\v\0,\1>6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0029\2\4\0025\4\23\0005\5\r\0005\6\b\0005\a\6\0009\b\5\1=\b\a\a=\a\t\0065\a\n\0009\b\5\1=\b\v\a=\a\f\6=\6\14\0055\6\15\0=\6\16\0055\6\20\0005\a\17\0005\b\18\0=\b\19\a=\a\21\6=\6\22\5=\5\24\0045\5\31\0005\6\30\0005\a\29\0005\b\27\0009\t\25\0009\n\26\0 \t\n\t=\t\28\b=\b\t\a=\a\14\6=\6 \5=\5!\0045\5&\0004\6\3\0006\a\0\0'\t\"\0B\a\2\0029\a#\a5\t%\0005\n$\0=\n\16\tB\a\2\0?\a\0\0=\6'\0055\6(\0005\a)\0=\a\16\6=\6*\5=\5+\4B\2\2\1K\0\1\0\15extensions\17file_browser\1\0\1\20prompt_position\btop\1\0\1\ntheme\rdropdown\14ui-select\1\0\0\1\0\0\1\0\1\20prompt_position\btop\17get_dropdown\21telescope.themes\fpickers\fbuffers\1\0\0\1\0\0\1\0\0\n<c-q>\1\0\0\16move_to_top\18delete_buffer\rdefaults\1\0\0\17path_display\fshorten\1\0\0\fexclude\1\3\0\0\3ÿÿÿÿ\15\3þÿÿÿ\15\1\0\1\blen\3\2\18layout_config\1\0\1\20prompt_position\vbottom\rmappings\1\0\1\20layout_strategy\16bottom_pane\6n\n<c-t>\1\0\0\6i\1\0\0\n<c-d>\1\0\0\22open_with_trouble\nsetup\14telescope trouble.providers.telescope\22telescope.actions\frequire\3À\4\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
