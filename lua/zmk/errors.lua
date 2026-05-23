local E = {
	dev_error = 'zmk.nvim: [E00] This is a dev error, please report this on the repo with your config',
	parse_error_msg = function(msg)
		return msg .. ' | see :help zmk-setup for available configuration options'
	end,

	keymaps_none = 'zmk.nvim: [E01] No keymaps found',
	keymaps_too_many = 'zmk.nvim: [E02] Found more than one keymap declaration',
	keymaps_overlap = 'zmk.nvim: [E03] One ore more keymap declarations overlap with the start and or end of the keymaps declaration',
	keymap_empty = function(name)
		return 'zmk.nvim: [E04] No keys found in keymap ' .. name
	end,

	config_too_many_keys = 'zmk.nvim: [E05] too many keys in the keymap for your configured layout',
	config_too_few_keys = 'zmk.nvim: [E06] not enough keys in the keymap for your configured layout',
	config_invalid_symbol = 'zmk.nvim: [E07] invalid layout token, expected a positive integer or "_"',
	key_index_duplicate = function(idx)
		return 'zmk.nvim: [E08] key index '
			.. tostring(idx)
			.. ' appears in multiple rows (vertical spans are not supported)'
	end,
	key_index_out_of_range = function(idx, max_keys)
		return 'zmk.nvim: [E19] key index '
			.. tostring(idx)
			.. ' is out of range, layout has '
			.. tostring(max_keys)
			.. ' keys'
	end,
	key_index_missing = function(idx)
		return 'zmk.nvim: [E20] layout is missing key index ' .. tostring(idx)
	end,

	config_missing = 'zmk.nvim: [E09] user_config is required for setup()',
	config_missing_required = 'zmk.nvim: [E10] config missing, required key is layout',
	config_keymap_invalid_pair = function(key, value)
		return (
			'zmk.nvim: [E11] keymap_overrides must be a dictionary of string keys and values, invalid: { '
				.. key
			or 'nil' .. '=' .. value
			or 'nil' .. ' }'
		)
	end,

	layout_empty = 'zmk.nvim: [E12] layout is empty',
	layout_row_empty = 'zmk.nvim: [E13] layout.row is empty',
	layout_trailing_whitespace = 'zmk.nvim: [E14] layout starts or ends with whitespace, use a gap "_" or span "x^" to create spaces',
	layout_double_whitespace = 'zmk.nvim: [E15] layout contains two or more adjacent spaces, use a gap "_" or span "x^" to create spaces',
	layout_missing_padding = 'zmk.nvim: [E16] layout row missing padding, all rows must be the same length, use gap "_" to pad out empty columns',

	parse_unknown = function(prefix, option)
		return 'zmk.nvim: [E17] ' .. string.format('unknown option: %s%s', prefix, option)
	end,
	parse_invalid = function(prefix, option, expected, got)
		return 'zmk.nvim: [E18] '
			.. string.format(
				'invalid option: "%s%s", expected: %s, got: %s',
				prefix,
				option,
				expected,
				got
			)
	end,
}

return E
