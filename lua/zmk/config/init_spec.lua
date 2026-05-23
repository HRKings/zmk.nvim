local E = require('zmk.errors')
local match = assert.combinators.match
local match_string = require('matcher_combinators.matchers.string')
local config = require('zmk.config')
local format = require('zmk.format.utils')

local function none_missing(conf)
	return vim.tbl_deep_extend('force', { layout = { '1' } }, conf)
end

describe('config', function()
	describe('abuse', function()
		local tests = {
			{
				msg = 'no config',
				input = nil,
				err = E.config_missing,
			},
			{
				msg = 'no layout',
				input = {},
				err = E.config_missing_required,
			},
			{
				msg = 'invalid key',
				input = none_missing({ foo = {} }),
				err = E.parse_error_msg(E.parse_unknown('', 'foo')),
			},
			{
				msg = 'invalid nested param',
				input = none_missing({
					comment_preview = { keymap_overrides = 0 },
				}),
				err = E.parse_error_msg(
					E.parse_invalid('comment_preview.', 'keymap_overrides', 'table', 'number')
				),
			},
			{
				msg = 'invalid complex param',
				input = none_missing({ comment_preview = { position = 'foo' } }),
				err = 'zmk.nvim: [E18] invalid option: "comment_preview.position", expected: one of top, bottom, inside, none,'
					.. ' got: foo | see :help zmk-setup for available configuration options',
			},
			{
				msg = 'invalid layout empty',
				input = none_missing({ layout = {} }),
				err = E.layout_empty,
			},
			{
				msg = 'invalid layout empty row',
				input = none_missing({ layout = { '' } }),
				err = E.layout_row_empty,
			},
			{
				msg = 'invalid layout uneven',
				input = none_missing({ layout = { '1', '2 3' } }),
				err = E.layout_missing_padding,
			},
			{
				msg = 'invalid layout trailing space',
				input = none_missing({ layout = { ' 1' } }),
				err = E.layout_trailing_whitespace,
			},
			{
				msg = 'invalid layout leading space',
				input = none_missing({ layout = { '1 ' } }),
				err = E.layout_trailing_whitespace,
			},
			{
				msg = 'invalid layout symbol (alpha)',
				input = none_missing({ layout = { '1 2 y' } }),
				err = E.config_invalid_symbol,
			},
			{
				msg = 'invalid layout symbol (zero)',
				input = none_missing({ layout = { '1 0' } }),
				err = E.config_invalid_symbol,
			},
			{
				msg = 'duplicate key index across rows',
				input = none_missing({ layout = { '1 2', '2 3' } }),
				err = E.key_index_duplicate(2),
			},
		}

		for _, test in pairs(tests) do
			it(test.msg, function()
				local ok, err = pcall(config.parse, test.input)
				assert(not ok, 'no error thrown')
				match(match_string.equals(test.err), err)
			end)
		end

		local test = {
			msg = 'invalid param',
			input = none_missing({ auto_format_pattern = { '*.keymap', 3 } }),
			err = format.escape_magic_characters(
				E.parse_invalid('', 'auto_format_pattern', 'string or string[]', 'table')
			),
		}
		it(test.msg, function()
			local ok, err = pcall(config.parse, test.input)
			assert(not ok, 'no error thrown')
			match(match_string.regex(test.err), err)
		end)
	end)
end)
