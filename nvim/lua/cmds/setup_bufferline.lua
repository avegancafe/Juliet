local M = {}

function M.setup(buf_mode)
	local colors = require('void_colors')

	require('bufferline').setup({
		highlights = {
			indicator_selected = {
				fg = colors.purple,
			},
			separator = {
				fg = colors.buffer_bg
			},
			buffer_selected = {
				bold = false,
				underline = true,
			},

			numbers_selected = {
				underline = true,
				bold = false,
			},
			diagnostic_selected = {
				underline = true,
				bold = false,
			},
			hint_selected = {
				underline = true,
				bold = false,
			},
			hint_diagnostic_selected = {
				underline = true,
				bold = false,
			},
			info_selected = {
				underline = true,
				bold = false,
			},
			info_diagnostic_selected = {
				underline = true,
				bold = false,
			},
			warning_selected = {
				underline = true,
				bold = false,
			},
			warning_diagnostic_selected = {
				underline = true,
				bold = false,
			},
			error_selected = {
				underline = true,
				bold = false,
			},
			error_diagnostic_selected = {
				underline = true,
				bold = false,
			},
			pick_selected = {
				underline = true,
				bold = false,
			},
			pick_visible = {
				bold = false,
			},
			pick = {
				bold = false,
			},
		},
		options = {
			mode = buf_mode,
			show_buffer_icons = false,
			offsets = {
				{
					filetype = 'NvimTree',
					text = 'File Explorer',
					highlight = 'Directory',
					text_align = 'left',
				},
			},
			groups = {
				items = {
					{
						name = 'frontend',
						matcher = function(buf)
							return buf.path:match('%a/portal/frontend/%a')
						end,
					},
					{
						name = 'backend',
						matcher = function(buf)
							return buf.path:match('%a/portal/backend/%a')
						end,
					},
				},
			},
		},
	})
end

return M
