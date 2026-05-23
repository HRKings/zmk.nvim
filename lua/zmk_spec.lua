local testy = require('zmk._test_utils')
require('matcher_combinators.luassert')

describe('zmk', function()
	describe('api', function()
		it('is not configured by default', function()
			local zmk = require('zmk')
			assert.is_false(zmk.is_configured())
		end)

		it('is configured after setup', function()
			local zmk = require('zmk')
			zmk.setup({ layout = { 'x' } })
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
				layout = {
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'_ _ _ _ _ x x _ _ _ _ _',
				},
			})
			zmk.format(T.buff)

			assert.combinators.match(T.expected, T.buff_content())
		end)

		it('formats zmk keymaps with bottom preview', function()
			local T = testy.snapshot('dactyl-bottom.keymap')

			local zmk = require('zmk')
			zmk.setup({
				comment_preview = { position = 'bottom' },
				layout = {
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'_ _ _ _ _ x x _ _ _ _ _',
				},
			})
			zmk.format(T.buff)

			assert.combinators.match(T.expected, T.buff_content())
		end)

		it('formats inline zmk keymaps', function()
			local T = testy.snapshot('dactyl_inline.keymap')

			local zmk = require('zmk')
			zmk.setup({
				comment_preview = { position = 'top' },
				layout = {
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'x x x x x x x x x x x x',
					'_ _ _ _ _ x x _ _ _ _ _',
				},
			})
			zmk.format(T.buff)

			assert.combinators.match(T.expected, T.buff_content())
		end)
	end)
end)
