local config = require('zmk.config')
local utils = require('zmk.utils')
local format = require('zmk.commands.format')

local zmk = {}
local configured_warning = 'ZMK plugin is not configured. Please call zmk.setup() first'

-- setup ZMK plugin
-- creates user commands and autocmds to autoformat
---@param options zmk.UserConfig
function zmk.setup(options)
	utils.timeout = options and options.timeout or 5000

	local ok, config_or_error = pcall(config.parse, options)
	if not ok then
		utils.notify(config_or_error)
		return
	end

	zmk.options = config_or_error

	vim.api.nvim_create_user_command('ZMKFormat', function()
		zmk.format()
	end, { desc = 'Format all keymaps in buffer' })

	if config_or_error.auto_format_pattern then
		vim.api.nvim_create_autocmd('BufWritePre', {
			desc = 'Format keymap',
			group = vim.api.nvim_create_augroup('ZMK', {}),
			pattern = zmk.options.auto_format_pattern,
			callback = function()
				zmk.format()
			end,
		})
	end
end

function zmk.is_configured()
	return zmk.options ~= nil
end

-- format all ZMK keymaps in the current buffer
---@param buf? number buffer #default current
function zmk.format(buf)
	if not zmk.is_configured() then
		utils.notify(configured_warning)
		return
	end

	local ok, err = pcall(format, zmk.options, buf)
	if not ok then
		utils.notify(err)
	end
end

zmk.options = nil

return zmk
