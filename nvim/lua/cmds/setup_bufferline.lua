local M = {}

function M.setup(buf_mode)
	local colors = require('bamboo.colors')

	require('bufferline').setup({
		highlights = {
			indicator_selected = {
				fg = colors.green,
			},
			separator = {
				fg = colors.bg1,
			},
			buffer_selected = {
				bold = false,
				underline = false,
				italic = false,
			},

			numbers_selected = {
				underline = false,
				bold = false,
			},
			diagnostic_selected = {
				underline = false,
				bold = false,
			},
			hint_selected = {
				underline = false,
				bold = false,
			},
			hint_diagnostic_selected = {
				underline = false,
				bold = false,
			},
			info_selected = {
				underline = false,
				bold = false,
			},
			info_diagnostic_selected = {
				underline = false,
				bold = false,
			},
			warning_selected = {
				underline = false,
				bold = false,
			},
			warning_diagnostic_selected = {
				underline = false,
				bold = false,
			},
			error_selected = {
				underline = false,
				bold = false,
			},
			error_diagnostic_selected = {
				underline = false,
				bold = false,
			},
			pick_selected = {
				underline = false,
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
