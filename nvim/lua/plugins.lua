vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua luafile <afile>
augroup end
]])

buffer_current_tabmode = "buffers"

return require("packer").startup({
	function()
		use({
			"kyazdani42/nvim-tree.lua",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("nvim-tree").setup()
			end,
		})
		use("dense-analysis/ale")
		use("jiangmiao/auto-pairs")
		use("rhysd/committia.vim")
		use("wincent/loupe")
		use("kaicataldo/material.vim")
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
				})
			end,
		})
		use("frazrepo/vim-rainbow")
		use("dag/vim-fish")
		use("heavenshell/vim-jsdoc")
		use("MaxMEllon/vim-jsx-pretty")
		use("groenewege/vim-less")
		use("prettier/vim-prettier")
		use("tomlion/vim-solidity")
		use("tpope/vim-surround")
		use("vim-test/vim-test")
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
					ensure_installed = {
						"javascript",
						"typescript",
						"go",
						"bash",
						"lua",
						"vim",
						"norg",
					},
					ignore_install = {},
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = false,
					},
				})
			end,
		})
		-- use 'mhinz/vim-startify'
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
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("cmds/setup_bufferline").setup("buffers")
			end,
		})
		use("glepnir/dashboard-nvim")
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
		use("tikhomirov/vim-glsl")
		use("iloginow/vim-stylus")
		use("cespare/vim-toml")
		use({
			"folke/trouble.nvim",
			config = function()
				require("trouble").setup({})
			end,
		})
		use("tpope/vim-fugitive")
		use("tpope/vim-sleuth")
		use("fatih/vim-go")
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
								},
							},
						},
					},
				})
			end,
		})
		use({
			"nvim-lualine/lualine.nvim",
			requires = { "nvim-web-devicons" },
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
	end,
	auto_reload_compiled = true,
})
