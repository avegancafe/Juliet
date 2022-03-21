vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua luafile <afile>
augroup end
]])

return require("packer").startup({
	function()
		use({
			"dsych/galaxyline.nvim",
			branch = "bugfix/diagnostics",
			config = function()
				require("statusline")
			end,
			requires = { "kyazdani42/nvim-web-devicons" },
		})
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
		use("junegunn/goyo.vim")
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
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"javascript",
						"typescript",
						"go",
						"bash",
						"lua",
						"vim",
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
		use("habamax/vim-godot")
		use("sbdchd/neoformat")
		use({
			"akinsho/bufferline.nvim",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("bufferline").setup({
					options = {
						diagnostics = "nvim_lsp",
						diagnostics_indicator = function(count, level, diagnostics_dict, context)
							local s = " "
							for e, n in pairs(diagnostics_dict) do
								local sym = e == "error" and " " or (e == "warning" and " " or "")
								s = s .. n .. sym
							end
							return s
						end,
						separator_style = "slant",
						offsets = {
							{
								filetype = "NvimTree",
								text = "File Explorer",
								highlight = "Directory",
								text_align = "left",
							},
						},
					},
				})
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
		use("reasonml-editor/vim-reason-plus")
		use("jordwalke/vim-reasonml")
		use("tpope/vim-fugitive")
		use("tpope/vim-sleuth")
		use("fatih/vim-go")
	end,
	auto_reload_compiled = true,
})
