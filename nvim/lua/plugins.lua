local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

buffer_current_tabmode = 'buffers'

require('lazy').setup({
	{
		'kyazdani42/nvim-tree.lua',
		dependencies = 'kyazdani42/nvim-web-devicons',
		config = function()
			require('nvim-tree').setup()
		end,
	},
	{
		'RRethy/vim-illuminate',
		config = function()
			require('illuminate').configure({
				filetypes_denylist = {
					'dashboard',
					'lspsagaoutline',
					'NvimTree',
				},
			})
		end,
	},
	{
		'glepnir/lspsaga.nvim',
		event = 'BufRead',
		config = function()
			require('lspsaga').setup({
				outline = {
					keys = {
						jump = '<cr>',
						expand_collapse = 'u',
					},
				},
				ui = {
					border = 'rounded',
				},
				symbol_in_winbar = {
					enable = false,
					separator = '  ',
					hide_keyword = false,
					show_file = true,
					respect_root = true,
					color_mode = true,
				},
			})
		end,
		dependencies = {
			{ 'kyazdani42/nvim-web-devicons' },
			{ 'nvim-treesitter/nvim-treesitter' },
		},
	},
	{ 'rhysd/committia.vim' },
	{
		'mfussenegger/nvim-lint',
		config = function()
			require('lint').linters_by_ft = {
				go = { 'golangcilint' },
			}
			local golangcilint = require('lint.linters.golangcilint')

			golangcilint.append_fname = true

			golangcilint.args = {
				'run',
				'--out-format',
				'json',
				'--config',
				'~/workspace/api-v2-backend/.build/scripts/.golangci.yml',
			}

			vim.cmd([[
				augroup lint
				au InsertLeave <buffer> lua require('lint').try_lint()
				augroup END
				]])
		end,
	},
	'wincent/loupe',
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'kyazdani42/nvim-web-devicons', 'nvim-lua/plenary.nvim' },
		config = function()
			local actions = require('telescope.actions')
			local trouble = require('trouble.providers.telescope')

			require('telescope').setup({
				defaults = {
					mappings = {
						i = {
							['<c-o>'] = function(prompt_bufnr, _mode)
								require('trouble.providers.telescope').open_with_trouble(prompt_bufnr, _mode)
							end,
							['<c-j>'] = actions.move_selection_next,
							['<c-k>'] = actions.move_selection_previous,
						},
						n = { ['<c-t>'] = trouble.open_with_trouble },
					},
					layout_config = { prompt_position = 'bottom' },
					layout_strategy = 'bottom_pane',
					path_display = {
						shorten = {
							len = 2,
							exclude = { -1, -2 },
						},
					},
				},
				pickers = {
					find_files = {
						find_command = {
							'fd',
							'--hidden',
							'--glob',
							'',
							'--type',
							'file',
						},
					},
					live_grep = {
						file_ignore_patterns = { 'node_modules', '.git' },
						find_command = 'rg',
						additional_args = function()
							return {
								'--no-heading',
								'--with-filename',
								'--line-number',
								'--column',
								'--hidden',
								'--smart-case',
							}
						end,
					},
					buffers = {
						mappings = {
							i = { ['<c-q>'] = actions.delete_buffer + actions.move_to_top },
						},
					},
				},
				extensions = {
					['ui-select'] = {
						require('telescope.themes').get_dropdown({
							layout_config = { prompt_position = 'top' },
						}),
					},
					file_browser = {
						theme = 'dropdown',
						layout_config = { prompt_position = 'top' },
						hidden = true,
						respect_gitignore = true,
					},
					workspaces = {
						keep_insert = false,
					},
				},
			})
		end,
	},
	'frazrepo/vim-rainbow',
	{
		'tomlion/vim-solidity',
		ft = 'solidity',
	},
	'tpope/vim-surround',
	'othree/yajs.vim',

	{
		'nvim-treesitter/nvim-treesitter',
		build = function()
			require('nvim-treesitter.install').update({ with_sync = true })
		end,
		config = function()
			vim.api.nvim_create_autocmd({ 'BufEnter', 'BufAdd', 'BufNew', 'BufNewFile', 'BufWinEnter' }, {
				group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
				callback = function()
					vim.opt.foldmethod = 'expr'
					vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
				end,
			})

			require('nvim-treesitter.configs').setup({
				ensure_installed = {
					'bash',
					'cmake',
					'comment',
					'css',
					'dockerfile',
					'fish',
					'gitignore',
					'go',
					'gomod',
					'graphql',
					'html',
					'http',
					'javascript',
					'jsdoc',
					'json',
					'json5',
					'latex',
					'lua',
					'make',
					'markdown',
					'markdown_inline',
					'ocaml',
					'python',
					'regex',
					'ruby',
					'rust',
					'scss',
					'solidity',
					'sql',
					'svelte',
					'swift',
					'todotxt',
					'toml',
					'tsx',
					'typescript',
					'vim',
					'vue',
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
			})
		end,
	},
	{
		'lewis6991/gitsigns.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('gitsigns').setup()
		end,
	},
	{
		'Th3Whit3Wolf/space-nvim',
		config = function()
			local void = require('void')

			require('space-nvim')(
				void['highlight_group_normal'],
				void['highlight_groups'],
				void['terminal_ansi_colors']
			)
			vim.cmd('colorscheme void')
		end,
	},

	{
		'williamboman/mason.nvim',
		'williamboman/mason-lspconfig.nvim',
		'neovim/nvim-lspconfig',
	},

	'sbdchd/neoformat',
	{
		'akinsho/bufferline.nvim',
		dependencies = { 'kyazdani42/nvim-web-devicons', 'Th3Whit3Wolf/space-nvim' },
		config = function()
			require('cmds/setup_bufferline').setup('buffers')
		end,
	},
	{
		'glepnir/dashboard-nvim',
		event = 'VimEnter',
		config = function()
			local utils = require('telescope.utils')
			local custom_footer = {}

			local function get_dashboard_git_status()
				local git_cmd = { 'git', 'status', '-s', '--', '.' }
				local output = utils.get_os_command_output(git_cmd)

				if #output == 0 then
					custom_footer = { '', '', 'Git status', '', 'No files changed' }
				else
					custom_footer = { '', '', 'Git status', '', unpack(output) }
				end
			end

			if ret ~= 0 then
				local is_worktree = utils.get_os_command_output(
					{ 'git', 'rev-parse', '--is-inside-work-tree' },
					vim.loop.cwd()
				)
				if is_worktree[1] == 'true' then
					get_dashboard_git_status()
				else
					local socket = io.popen('fortune')
					local fortune = socket:read('*a')
					socket:close()

					local footer = {}
					for s in fortune:gmatch('[^\r\n]+') do
						table.insert(footer, s)
					end

					custom_footer = footer
				end
			else
				get_dashboard_git_status()
			end
			require('dashboard').setup({
				theme = 'doom',
				config = {
					header = {
						'            ',
						'            ',
						'    ↑↑↓↓    ',
						'   ←→←→AB   ',
						'   ┌────┐   ',
						'   │    ├┐  ',
						'   │┌ ┌ └│  ',
						'   │ ╘  └┘  ',
						'   │    │   ',
						'   │╙─  │   ',
						'   │    │   ',
						'   └──┘ │   ',
						'     │  │   ',
						'     │  │   ',
						'            ',
						'            ',
						'            ',
					},
					footer = custom_footer,
					packages = { enable = false },
					mru = { limit = 5 },
					shortcut = {
						{
							desc = 'Last Session',
							key = 'l',
							group = 'DashboardMruTitle',
							action = 'SessionManager load_current_dir_session',
						},
						{
							desc = 'Find file',
							group = 'DashboardMruTitle',
							key = 'p',
							action = 'Telescope find_files',
						},
						{
							desc = 'Find word',
							group = 'DashboardMruTitle',
							key = 'f',
							action = 'Telescope live_grep',
						},
					},
					center = {
						{
							desc = 'Last Session             ',
							icon = ' ',
							key = 'l',
							action = 'SessionManager load_current_dir_session',
						},
						{
							desc = 'Find file               ',
							icon = ' ',
							key = 'p',
							action = 'Telescope find_files',
						},
						{
							desc = 'New file                     ',
							key = 'n',
							icon = ' ',
							action = 'DashboardNewFile',
						},
						{
							desc = 'Find word                    ',
							key = 'w',
							icon = ' ',
							action = 'Telescope live_grep',
						},
					},
				},
			})
		end,
	},

	{
		'Yggdroot/indentLine',
		config = function()
			vim.g.indentLine_fileTypeExclude = { 'dashboard' }
			vim.g.indentLine_concealcursor = 'n'
		end,
	},
	{
		'terrortylor/nvim-comment',
		config = function()
			require('nvim_comment').setup({
				line_mapping = '<leader>cc',
				operator_mapping = '<leader>c',
			})
		end,
	},
	{
		'folke/trouble.nvim',
		config = function()
			require('trouble').setup({})
		end,
	},
	'tpope/vim-sleuth',
	{
		'folke/zen-mode.nvim',
		config = function()
			require('zen-mode').setup({
				window = {
					backdrop = 1,
					height = 0.73,
					options = {
						number = false,
						relativenumber = false,
					},
				},
			})
		end,
	},

	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-web-devicons', 'avegancafe/do.nvim' },
		config = function()
			local navic = require('nvim-navic')
			require('lualine').setup({
				winbar = {
					lualine_c = {
						function()
							return require('do').view('active')
						end,
					},
				},
				inactive_winbar = {
					lualine_c = {
						function()
							return require('do').view('inactive')
						end,
					},
				},
				options = {
					component_separators = {
						left = '',
						right = '',
					},
					section_separators = {
						left = '',
						right = '',
					},
					theme = require('lualine_theme'),
					disabled_filetypes = {
						statusline = {
							'lspsagaoutline',
							'NvimTree',
						},
						winbar = {
							'lspsagaoutline',
							'NvimTree',
							'dashboard',
						},
					},
				},
				sections = {
					lualine_a = { 'mode' },
					lualine_b = {
						function()
							local output = vim.split(vim.api.nvim_exec('WorkspacesList', true), '\n')

							for i = 0, table.getn(output) do
								if output[i] ~= nil then
									local path = string.gsub(output[i], '[%a%A]* ', '')
									path = string.gsub(path, '/$', '')
									if path == vim.api.nvim_exec('pwd', true) then
										return string.gsub(output[i], ' [%a%A/]+', '')
									end
								end
							end

							return ''
						end,
						{
							'filename',
							cond = function()
								return require('lspsaga.symbolwinbar'):get_winbar() == nil
							end,
						},
					},
					lualine_c = {
						{
							function()
								return (require('lspsaga.symbolwinbar'):get_winbar() .. '%#EndOfBuffer#') or ''
							end,
						},
						'diagnostics',
					},
					lualine_x = { 'lsp_progres' },
					lualine_y = { 'filetype' },
					lualine_z = {
						{
							function()
								return '|'
							end,
							color = { fg = require('void_colors').bg },
						},
						{
							function()
								return ''
							end,
							color = { fg = require('void_colors').red },
						},
					},
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { 'filename' },
					lualine_x = { 'location' },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},
	{
		'Shatur/neovim-session-manager',
		config = function()
			require('session_manager').setup({
				autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
				max_path_length = 0,
			})
		end,
	},
	{
		'nvim-telescope/telescope-ui-select.nvim',
		config = function()
			require('telescope').load_extension('ui-select')
		end,
	},
	{
		'nvim-telescope/telescope-file-browser.nvim',
		config = function()
			require('telescope').load_extension('file_browser')
		end,
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			'neovim/nvim-lspconfig',
			'L3MON4D3/LuaSnip',
			'hrsh7th/cmp-buffer',
		},
		config = function()
			local cmp = require('cmp')

			cmp.setup({
				sorting = {
					comparators = {
						cmp.config.compare.locality,
						cmp.config.compare.exact,
						cmp.config.compare.offset,
						cmp.config.compare.score,
						cmp.config.compare.sort_text,
					},
				},
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					['<C-e>'] = cmp.mapping.abort(),
					['<Tab>'] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'buffer' },
				}),
			})
		end,
	},
	'vimpostor/vim-tpipeline',
	'dstein64/vim-startuptime',

	{
		'folke/todo-comments.nvim',
		dependencies = 'nvim-lua/plenary.nvim',
		config = function()
			require('todo-comments').setup({
				keywords = {
					FIX = { color = 'warning' },
				},
				highlight = {
					pattern = [[.*<(KEYWORDS)\s*]],
					keyword = 'bg',
				},
			})
		end,
	},

	{
		'smjonas/inc-rename.nvim',
		config = true,
	},

	{
		'j-hui/fidget.nvim',
		config = function()
			require('fidget').setup({
				text = {
					spinner = 'dots',
					done = '✓',
				},
				timer = {
					spinner_rate = 50,
				},
			})
		end,
	},

	{
		'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
		config = function()
			require('lsp_lines').setup()
			vim.diagnostic.config({
				virtual_text = false,
			})
		end,
	},

	{
		'liuchengxu/vista.vim',
		config = function()
			vim.g.vista_default_executive = 'nvim_lsp'
			vim.g.vista_echo_cursor = 0
		end,
	},

	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'make',
		config = function()
			-- require('telescope').load_extension('fzf')
		end,
	},

	'Eandrju/cellular-automaton.nvim',

	{
		'klen/nvim-test',
		config = function()
			-- vim.cmd([[
			-- 		augroup nvim_test_runner
			-- 			autocmd!
			-- 			autocmd BufWritePost *.go TestFile
			-- 		augroup end
			-- 	]])

			require('nvim-test').setup({
				run = true,
				commands_create = true,
				filename_modifier = ':.',
				silent = false,
				term = 'terminal',
				termOpts = {
					direction = 'vertical',
					width = 96,
					height = 24,
					go_back = false,
					stopinsert = 'auto',
					keep_one = true,
				},
				runners = {
					go = 'nvim-test.runners.go-test',
				},
			})

			require('nvim-test.runners.go-test'):setup({
				command = 'relay-test',
				args = {},
				env = {
					RCORE_TEST_CONFIG = '/Users/kyle/workspace/dev-env/relay-rcore-testing.toml',
					RELAY_TEST_CONFIG = '/Users/kyle/workspace/dev-env/relay-core-testing.toml',
					RPOS_TEST_CONFIG = '/Users/kyle/workspace/dev-env/relay-portal-testing.toml',
				},
			})
		end,
	},

	{
		'sotte/presenting.vim',
		config = function()
			vim.g.presenting_font_large = 'starwars'
			vim.g.presenting_font_small = 'speed'
		end,
	},

	{
		'kevinhwang91/nvim-ufo',
		dependencies = 'kevinhwang91/promise-async',
		config = function()
			require('ufo').setup()
		end,
	},

	{
		'SmiteshP/nvim-navic',
		dependencies = 'neovim/nvim-lspconfig',
	},

	{
		'avegancafe/do.nvim',
		config = true,
		opts = {
			doing_prefix = 'In progress: ',
			winbar = false,
			store = {
				file_name = '.todo',
				auto_create_file = true,
			},
		},
	},

	{
		'natecraddock/workspaces.nvim',
		dependencies = { 'Shatur/neovim-session-manager', 'nvim-telescope/telescope.nvim' },
		config = function()
			local workspaces = require('workspaces')
			workspaces.setup({
				hooks = {
					open = function()
						require('session_manager').load_current_dir_session()
					end,
				},
			})

			require('telescope').load_extension('workspaces')
		end,
	}
})
