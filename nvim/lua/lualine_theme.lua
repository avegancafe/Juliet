local colors = require('void_colors')

return {
	normal = {
		a = { bg = colors.bg, fg = colors.fg, gui = 'bold' },
		b = { bg = colors.section_bg, fg = colors.fg },
		c = { bg = colors.bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	insert = {
		a = { bg = colors.blue, fg = colors.bg, gui = 'bold' },
		b = { bg = colors.section_bg, fg = colors.fg },
		c = { bg = colors.bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	visual = {
		a = { bg = colors.yellow, fg = colors.bg, gui = 'bold' },
		b = { bg = colors.section_bg, fg = colors.fg },
		c = { bg = colors.bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	replace = {
		a = { bg = colors.red, fg = colors.bg, gui = 'bold' },
		b = { bg = colors.section_bg, fg = colors.fg },
		c = { bg = colors.bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	command = {
		a = { bg = colors.green, fg = colors.bg, gui = 'bold' },
		b = { bg = colors.section_bg, fg = colors.fg },
		c = { bg = colors.bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	inactive = {
		a = { bg = colors.bg, fg = colors.bg, gui = 'bold' },
		b = { bg = colors.section_bg, fg = colors.bg },
		c = { bg = colors.bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
}
