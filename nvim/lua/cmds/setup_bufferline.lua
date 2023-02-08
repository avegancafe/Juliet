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
