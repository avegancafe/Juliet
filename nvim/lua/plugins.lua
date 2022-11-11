local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({
		'git',
		'clone',
		'--depth',
		'1',
		'https://github.com/wbthomason/packer.nvim',
		install_path,
	})
	vim.api.nvim_command('packadd packer.nvim')
end

vim.cmd([[
augroup packer_user_config
	autocmd!
	autocmd BufWritePost plugins.lua luafile <afile>
	autocmd BufWritePost plugins.lua PackerCompile
	autocmd BufWritePost plugins.lua PackerInstall
augroup end
]])

buffer_current_tabmode = 'buffers'

return require('packer').startup({
	function(use)
		use('wbthomason/packer.nvim')
		use({
			'kyazdani42/nvim-tree.lua',
			requires = 'kyazdani42/nvim-web-devicons',
			config = function()
				require('nvim-tree').setup()
			end,
		})
		use({ 'rhysd/committia.vim' })
		use({
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
		})
		use('wincent/loupe')
		use({
			'nvim-telescope/telescope.nvim',
			requires = { 'kyazdani42/nvim-web-devicons', 'nvim-lua/plenary.nvim' },
			config = function()
				local actions = require('telescope.actions')
				local trouble = require('trouble.providers.telescope')

				require('telescope').setup({
					defaults = {
						mappings = {
							i = {
								['<c-d>'] = trouble.open_with_trouble,
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
					},
				})
			end,
		})
		use('frazrepo/vim-rainbow')
		use({
			'tomlion/vim-solidity',
			ft = 'solidity',
		})
		use('tpope/vim-surround')
		use('othree/yajs.vim')
		use({
			'nvim-treesitter/nvim-treesitter',
			run = function()
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
		})
		use({
			'lewis6991/gitsigns.nvim',
			requires = { 'nvim-lua/plenary.nvim' },
			config = function()
				require('gitsigns').setup()
			end,
		})
		use({
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
		})
		use({
			'neovim/nvim-lspconfig',
			requires = { 'williamboman/nvim-lsp-installer' },
			config = function()
				require('lspconfig').ocamllsp.setup({})
			end,
		})
		use('sbdchd/neoformat')
		use({
			'akinsho/bufferline.nvim',
			requires = { 'kyazdani42/nvim-web-devicons' },
			after = 'space-nvim',
			config = function()
				require('cmds/setup_bufferline').setup('buffers')
			end,
		})
		use({
			'glepnir/dashboard-nvim',
			config = function()
				local db = require('dashboard')

				db.custom_header = {
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
				}

				local utils = require('telescope.utils')

				local function get_dashboard_git_status()
					local git_cmd = { 'git', 'status', '-s', '--', '.' }
					local output = utils.get_os_command_output(git_cmd)

					if #output == 0 then
						db.custom_footer = { '', '', 'Git status', '', 'No files changed' }
					else
						db.custom_footer = { '', '', 'Git status', '', unpack(output) }
					end
				end

				if ret ~= 0 then
					local is_worktree =
						utils.get_os_command_output({ 'git', 'rev-parse', '--is-inside-work-tree' }, vim.loop.cwd())
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

						db.custom_footer = footer
					end
				else
					get_dashboard_git_status()
				end

				db.custom_center = {
					{
						desc = 'Last Session             ',
						icon = ' ',
						shortcut = '\\ s l',
						action = 'SessionManager load_current_dir_session',
					},
					{
						desc = 'Find file               ',
						icon = ' ',
						shortcut = 'ctrl p',
						action = 'Telescope find_files',
					},
					{
						desc = 'New file                     ',
						icon = ' ',
						action = 'DashboardNewFile',
					},
					{
						desc = 'Find word                    ',
						icon = ' ',
						action = 'call v:lua.TelescopeGrep()',
					},
				}
			end,
		})
		use({
			'Yggdroot/indentLine',
			config = function()
				vim.g.indentLine_fileTypeExclude = { 'dashboard', 'packer' }
				vim.g.indentLine_concealcursor = 'n'
			end,
		})
		use({
			'terrortylor/nvim-comment',
			config = function()
				require('nvim_comment').setup({
					line_mapping = '<leader>cc',
					operator_mapping = '<leader>c',
				})
			end,
		})
		use({
			'folke/trouble.nvim',
			config = function()
				require('trouble').setup({})
			end,
		})
		use('tpope/vim-sleuth')
		use({
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
		})
		use({
			'nvim-lualine/lualine.nvim',
			requires = { 'nvim-web-devicons' },
			config = function()
				require('lualine').setup({
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
					},
					sections = {
						lualine_a = { 'mode' },
						lualine_b = { 'filename' },
						lualine_c = { 'diagnostics' },
						lualine_x = {},
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
		})
		use({
			'Shatur/neovim-session-manager',
			config = function()
				require('session_manager').setup({
					autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
					max_path_length = 0,
				})
			end,
		})
		use({
			'nvim-telescope/telescope-ui-select.nvim',
			after = 'telescope.nvim',
			config = function()
				require('telescope').load_extension('ui-select')
			end,
		})
		use({
			'nvim-telescope/telescope-file-browser.nvim',
			after = 'telescope.nvim',
			config = function()
				require('telescope').load_extension('file_browser')
			end,
		})
		use({
			'hrsh7th/nvim-cmp',
			requires = {
				'hrsh7th/cmp-nvim-lsp',
				'neovim/nvim-lspconfig',
				'L3MON4D3/LuaSnip',
			},
			config = function()
				local cmp = require('cmp')

				cmp.setup({
					sorting = {
						comparators = {
							cmp.config.compare.offset,
							cmp.config.compare.exact,
							cmp.config.compare.score,
							cmp.config.compare.kind,
							cmp.config.compare.sort_text,
							cmp.config.compare.length,
							cmp.config.compare.order,
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
						['<CR>'] = cmp.mapping.confirm({ select = true }),
						['<Tab>'] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources(
						{ { name = 'nvim_lsp' }, { name = 'luasnip' } },
						{ { name = 'buffer' } }
					),
				})
			end,
		})
		use('vimpostor/vim-tpipeline')
		use('dstein64/vim-startuptime')
	end,
	auto_reload_compiled = true,
	config = {
		display = {
			open_fn = function()
				return require('packer.util').float({ border = 'rounded' })
			end,
		},
		profile = {
			enable = true,
		},
	},
})
