local M = {}

-- use for validation
---@type zmk.UserConfig
M.required_fields = {
	layout = { '' },
}

---@type zmk.UserConfig
M.default_config = {
	layout = { '' },
	timeout = 5000,
	auto_format_pattern = { '*.keymap' },
	comment_preview = {
		position = 'top',
		keymap_overrides = {},
		symbols = {
			space = ' ',
			horz = '─',
			vert = '│',
			tl = '┌',
			tm = '┬',
			tr = '┐',
			ml = '├',
			mm = '┼',
			mr = '┤',
			bl = '└',
			bm = '┴',
			br = '┘',
		},
	},
}

return M
