local testy = require('zmk._test_utils')
require('matcher_combinators.luassert')

local dactyl_layout = {
	'1  2  3  4  5  6  7  8  9  10 11 12',
	'13 14 15 16 17 18 19 20 21 22 23 24',
	'25 26 27 28 29 30 31 32 33 34 35 36',
	'37 38 39 40 41 42 43 44 45 46 47 48',
	'49 50 51 52 53 54 55 56 57 58 59 60',
	'_  _  _  _  _  61 62 _  _  _  _  _',
}

describe('zmk', function()
	describe('api', function()
		it('is not configured by default', function()
			local zmk = require('zmk')
			assert.is_false(zmk.is_configured())
		end)

		it('is configured after setup', function()
			local zmk = require('zmk')
			zmk.setup({ layout = { '1' } })
			assert.is_true(zmk.is_configured())
		end)

		it('warns of invalid config but does not throw', function()
			local zmk = require('zmk')
			local spy = require('luassert.spy')
			spy.on(vim, 'notify')
			local ok = pcall(zmk.setup)
			assert(ok, 'no error should be thrown')
			assert.spy(vim.notify).was_called()
		end)
	end)

	describe('format', function()
		it('formats zmk keymaps', function()
			local T = testy.snapshot('dactyl.keymap')

			local zmk = require('zmk')
			zmk.setup({
				comment_preview = { position = 'top' },
				layout = dactyl_layout,
			})
			zmk.format(T.buff)

			assert.combinators.match(T.expected, T.buff_content())
		end)

		it('formats zmk keymaps with bottom preview', function()
			local T = testy.snapshot('dactyl-bottom.keymap')

			local zmk = require('zmk')
			zmk.setup({
				comment_preview = { position = 'bottom' },
				layout = dactyl_layout,
			})
			zmk.format(T.buff)

			assert.combinators.match(T.expected, T.buff_content())
		end)

		it('formats inline zmk keymaps', function()
			local T = testy.snapshot('dactyl_inline.keymap')

			local zmk = require('zmk')
			zmk.setup({
				comment_preview = { position = 'top' },
				layout = dactyl_layout,
			})
			zmk.format(T.buff)

			assert.combinators.match(T.expected, T.buff_content())
		end)
	end)
end)
