return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#252623',
				base01 = '#252623',
				base02 = '#7d837a',
				base03 = '#7d837a',
				base04 = '#9ea49a',
				base05 = '#e0e3dd',
				base06 = '#e0e3dd',
				base07 = '#e0e3dd',
				base08 = '#d39384',
				base09 = '#d39384',
				base0A = '#8bac75',
				base0B = '#7ebc7a',
				base0C = '#c5dbb6',
				base0D = '#8bac75',
				base0E = '#accc96',
				base0F = '#accc96',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#7d837a',
				fg = '#e0e3dd',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#8bac75',
				fg = '#252623',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#7d837a' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#c5dbb6', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#accc96',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#8bac75',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#8bac75',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#c5dbb6',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#7ebc7a',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#9ea49a' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#9ea49a' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#7d837a',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
