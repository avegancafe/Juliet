local colors = {
	bg = "#282a2e",
	fg = "#f8f8f2",
	section_bg = "#38393f",
	yellow = "#f1fa8c",
	cyan = "#8be9fd",
	green = "#50fa7b",
	orange = "#ffb86c",
	magenta = "#ff79c6",
	blue = "#8be9fd",
	red = "#ff5555",
}

return {
	normal = {
		a = { bg = colors.section_bg, fg = colors.fg, gui = "bold" },
		b = { bg = colors.bg, fg = colors.fg },
		c = { bg = colors.section_bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	insert = {
		a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg, fg = colors.fg },
		c = { bg = colors.section_bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	visual = {
		a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg, fg = colors.fg },
		c = { bg = colors.section_bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	replace = {
		a = { bg = colors.red, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg, fg = colors.fg },
		c = { bg = colors.section_bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	command = {
		a = { bg = colors.green, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg, fg = colors.fg },
		c = { bg = colors.section_bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
	inactive = {
		a = { bg = colors.bg, fg = colors.bg, gui = "bold" },
		b = { bg = colors.fg, fg = colors.bg },
		c = { bg = colors.section_bg, fg = colors.fg },
		z = { bg = colors.section_bg, fg = colors.red },
	},
}
