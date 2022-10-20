local M = {}

function M.setup(buf_mode)
	local colors = require('void_colors')
	require('bufferline').setup({
		highlights = {
			buffer_selected = {
				underline = true,
			},
		},
		options = {
			mode = buf_mode,
			show_buffer_icons = false,
			diagnostics = 'nvim_lsp',
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				local s = ' '
				for e, n in pairs(diagnostics_dict) do
					local sym = e == 'error' and 'x ' or (e == 'warning' and 'w ' or 'i')
					s = s .. n .. sym
				end
				return s
			end,
			separator_style = 'slant',
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
						name = 'tests',
						priority = 1,
						matcher = function(buf)
							return buf.name:match('%_test.go')
						end,
					},
				},
			},
		},
	})
end

return M
