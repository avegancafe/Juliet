vim.cmd([[
augroup packer_user_config
autocmd!
	autocmd BufWritePost plugins.lua luafile <afile>
	autocmd BufWritePost plugins.lua PackerInstall
	autocmd BufWritePost plugins.lua PackerCompile
augroup end
]])

buffer_current_tabmode = "buffers"

return require("packer").startup({
	function()
		use("wbthomason/packer.nvim")
		use("MaxMEllon/vim-jsx-pretty")
		use({
			"kyazdani42/nvim-tree.lua",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("nvim-tree").setup()
			end,
		})
		use("rhysd/committia.vim")
		use({
			"mfussenegger/nvim-lint",
			config = function()
				require("lint").linters_by_ft = {
					go = { "golangcilint" },
				}
				local golangcilint = require("lint.linters.golangcilint")

				golangcilint.append_fname = true

				golangcilint.args = {
					"run",
					"--out-format",
					"json",
					"--config",
					"~/workspace/api-v2-backend/.build/scripts/.golangci.yml",
				}

				vim.cmd([[
					augroup lint
						au InsertLeave <buffer> lua require('lint').try_lint()
					augroup END
				]])
			end,
		})
		use("wincent/loupe")
		use({
			"kassio/neoterm",
			config = function()
				vim.cmd("syntax enable")
			end,
		})
		use({
			"nvim-telescope/telescope.nvim",
			requires = { "kyazdani42/nvim-web-devicons", "nvim-lua/plenary.nvim" },
			config = function()
				local actions = require("telescope.actions")
				local trouble = require("trouble.providers.telescope")

				require("telescope").setup({
					defaults = {
						mappings = {
							i = {
								["<c-t>"] = trouble.open_with_trouble,
							},
							n = {
								["<c-t>"] = trouble.open_with_trouble,
							},
						},
						layout_config = {
							prompt_position = "bottom",
						},
						layout_strategy = "bottom_pane",
						path_display = {
							shorten = {
								len = 2,
								exclude = { -1, -2 },
							},
						},
					},
					pickers = {
						buffers = {
							mappings = {
								i = {
									["<c-q>"] = actions.delete_buffer + actions.move_to_top,
								},
							},
						},
					},
					extensions = {
						["ui-select"] = {
							require("telescope.themes").get_dropdown({
								layout_config = {
									prompt_position = "top",
								},
							}),
						},
						file_browser = {
							theme = "dropdown",
							layout_config = {
								prompt_position = "top",
							},
						},
					},
				})
			end,
		})
		use("frazrepo/vim-rainbow")
		use({
			"dag/vim-fish",
		})
		use("tomlion/vim-solidity")
		use("tpope/vim-surround")
		use("othree/yajs.vim")
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
			config = function()
				local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

				-- These two are optional and provide syntax highlighting
				-- for Neorg tables and the @document.meta tag
				parser_configs.norg_meta = {
					install_info = {
						url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
						files = { "src/parser.c" },
						branch = "main",
					},
				}

				parser_configs.norg_table = {
					install_info = {
						url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
						files = { "src/parser.c" },
						branch = "main",
					},
				}
				require("nvim-treesitter.configs").setup({
					ensure_installed = "all",
					ignore_install = { "phpdoc" },
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = false,
					},
				})
			end,
		})
		use({
			"lewis6991/gitsigns.nvim",
			requires = { "nvim-lua/plenary.nvim" },
			config = function()
				require("gitsigns").setup()
			end,
		})
		use({
			"Th3Whit3Wolf/space-nvim",
			config = function()
				void = require("void")
				require("space-nvim")(
					void["highlight_group_normal"],
					void["highlight_groups"],
					void["terminal_ansi_colors"]
				)
				vim.cmd("colorscheme void")
			end,
		})
		use({
			"neovim/nvim-lspconfig",
			requires = "williamboman/nvim-lsp-installer",
			config = function()
				require("lspconfig").ocamllsp.setup({})
			end,
		})
		use("sbdchd/neoformat")
		use({
			"akinsho/bufferline.nvim",
			requires = { "kyazdani42/nvim-web-devicons", "Th3Whit3Wolf/space-nvim" },
			config = function()
				require("cmds/setup_bufferline").setup("buffers")
			end,
		})
		use({
			"glepnir/dashboard-nvim",
			config = function()
				local db = require("dashboard")

				db.custom_header = {
					"            ",
					"            ",
					"    ↑↑↓↓    ",
					"   ←→←→AB   ",
					"   ┌────┐   ",
					"   │    ├┐  ",
					"   │┌ ┌ └│  ",
					"   │ ╘  └┘  ",
					"   │    │   ",
					"   │╙─  │   ",
					"   │    │   ",
					"   └──┘ │   ",
					"     │  │   ",
					"     │  │   ",
					"            ",
					"            ",
					"            ",
				}

				local utils = require("telescope.utils")
				local set_var = vim.api.nvim_set_var

				local git_root, ret = utils.get_os_command_output(
					{ "git", "rev-parse", "--show-toplevel" },
					vim.loop.cwd()
				)

				local function get_dashboard_git_status()
					local git_cmd = { "git", "status", "-s", "--", "." }
					local output = utils.get_os_command_output(git_cmd)

					if #output == 0 then
						db.custom_footer = { "", "", "Git status", "", "No files changed" }
					else
						db.custom_footer = { "", "", "Git status", "", unpack(output) }
					end
				end

				if ret ~= 0 then
					local is_worktree = utils.get_os_command_output(
						{ "git", "rev-parse", "--is-inside-work-tree" },
						vim.loop.cwd()
					)
					if is_worktree[1] == "true" then
						get_dashboard_git_status()
					else
						local socket = io.popen("fortune")
						local fortune = socket:read("*a")
						socket:close()

						local footer = {}
						for s in fortune:gmatch("[^\r\n]+") do
							table.insert(footer, s)
						end

						db.custom_footer = footer
					end
				else
					get_dashboard_git_status()
				end

				db.custom_center = {
					{
						desc = "Last Session             ",
						icon = " ",
						shortcut = "\\ s s",
						action = "SessionManager load_current_dir_session",
					},
					{
						desc = "Find file               ",
						icon = " ",
						shortcut = "ctrl p",
						action = "Telescope find_files",
					},
					{
						desc = "New file                     ",
						icon = " ",
						action = "DashboardNewFile",
					},
					{
						desc = "Find word                    ",
						icon = " ",
						action = "call v:lua.TelescopeGrep()",
					},
				}
			end,
		})
		use("Yggdroot/indentLine")
		use({
			"terrortylor/nvim-comment",
			config = function()
				require("nvim_comment").setup({
					line_mapping = "<leader>cc",
					operator_mapping = "<leader>c",
				})
			end,
		})
		use({
			"folke/trouble.nvim",
			config = function()
				require("trouble").setup({})
			end,
		})
		use("tpope/vim-sleuth")
		use({
			"folke/zen-mode.nvim",
			config = function()
				require("zen-mode").setup({
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
			"nvim-neorg/neorg",
			requires = { "folke/zen-mode.nvim" },
			config = function()
				require("neorg").setup({
					load = {
						["core.defaults"] = {},
						["core.norg.concealer"] = {},
						["core.presenter"] = {
							config = {
								zen_mode = "zen-mode",
							},
						},
						["core.norg.dirman"] = {
							config = {
								workspaces = {
									frontend = "~/workspace/api-v2-frontend",
									backend = "~/workspace/api-v2-backend",
									notes = "~/workspace/notes",
								},
							},
						},
					},
				})
			end,
		})
		use({
			"nvim-lualine/lualine.nvim",
			requires = { "nvim-web-devicons", "Th3Whit3Wolf/space-nvim" },
			config = function()
				require("lualine").setup({
					options = {
						component_separators = { left = "", right = "" },
						section_separators = { left = "", right = "" },
						theme = require("lualine_theme"),
					},
					sections = {
						lualine_a = { "mode" },
						lualine_b = { "filename" },
						lualine_c = { "diagnostics" },
						lualine_x = {},
						lualine_y = { "filetype" },
						lualine_z = {
							{
								function()
									return "|"
								end,
								color = { fg = require("void_colors").bg },
							},
							{
								function()
									return ""
								end,
								color = { fg = require("void_colors").red },
							},
						},
					},
					inactive_sections = {
						lualine_a = {},
						lualine_b = {},
						lualine_c = { "filename" },
						lualine_x = { "location" },
						lualine_y = {},
						lualine_z = {},
					},
					tabline = {},
					extensions = {},
				})
			end,
		})
		use("ray-x/lsp_signature.nvim")
		use({
			"Shatur/neovim-session-manager",
			config = function()
				require("session_manager").setup({
					autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
					max_path_length = 0,
				})
			end,
		})
		use({
			"nvim-telescope/telescope-ui-select.nvim",
			config = function()
				require("telescope").load_extension("ui-select")
			end,
		})
		use({
			"nvim-telescope/telescope-file-browser.nvim",
			config = function()
				require("telescope").load_extension("file_browser")
			end,
		})
	end,
	auto_reload_compiled = true,
})
