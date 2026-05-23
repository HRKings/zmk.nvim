local E = require('zmk.errors')
local check = require('zmk.utils').check
local validator = require('zmk.config.validator')
local config = require('zmk.config.default')
local key_map = require('zmk.config.key_map')

local M = {}

---@param layout zmk.UserLayout
---@return zmk.LayoutPlan
function M.parse_layout(layout)
	check(#layout > 0, E.layout_empty)

	local result = {}
	for row_i, row in pairs(layout) do
		check(#row > 0, E.layout_row_empty)

		-- check for trailing whitespace
		check(not vim.startswith(row, ' '), E.layout_trailing_whitespace)
		check(not vim.endswith(row, ' '), E.layout_trailing_whitespace)

		-- check for two white spaces in a row
		local invalid_whitespace = string.find(row, '  ', 1, true)
		check(not invalid_whitespace, E.layout_double_whitespace)

		-- check for uneven rows
		if row_i > 1 then
			check(#row == #layout[row_i - 1], E.layout_missing_padding)
		end

		---@diagnostic disable-next-line: missing-parameter
		local keys = vim.split(row, ' ')

		local row_info = vim.tbl_map(function(key)
			if key == '_' then
				return { width = 1, type = 'gap' }
			end
			if key == 'x' then
				return { width = 1, type = 'key' }
			end

			local invalid = string.find(key, '[^x^]')
			check(not invalid, E.config_invalid_symbol)
			local i = string.find(key, '^', 1, true)
			check(i, E.config_invalid_span)

			return {
				width = (string.len(key) + 1) / 2,
				type = 'span',
				align = tostring(i) .. '/' .. tostring(string.len(key)),
			}
		end, keys)

		result[#result + 1] = row_info
	end
	return result
end

local function merge(a, b)
	return vim.tbl_deep_extend('force', a, b)
end

---@param user_config zmk.UserConfig
---@return zmk.Config
function M.parse(user_config)
	check(user_config, E.config_missing)
	check(user_config.layout, E.config_missing_required)
	---@type zmk.Config
	local merged_config = merge(config.default_config, user_config)

	merged_config.layout = M.parse_layout(merged_config.layout)

	-- TODO: DI the validator
	validator(merged_config, config.default_config)

	local keymaps =
		merge(key_map.zmk_key_map, merged_config.comment_preview.keymap_overrides or {})
	local merged_sorted_config =
		merge(merged_config, { comment_preview = { keymap_overrides = key_map.sort(keymaps) } })

	return merged_sorted_config
end

return M

---------------------------------------------------------------------------------
---- PARSED CONFIG
---------------------------------------------------------------------------------

---The users config after parsing
---@class zmk.Config
---@field timeout number # if using nvim-notify, this will be the duration of the notification
---@field auto_format_pattern string | string[] # autocommand pattern to match against for auto formatting, e.g. '*.keymap'
---@field layout zmk.LayoutPlan
---@field comment_preview zmk.Preview

---@class zmk.Preview
---@field position 'top' | 'bottom' | 'none'
---@field keymap_overrides zmk.KeymapList
---@field symbols zmk.PreviewSymbols

---@alias zmk.KeymapList {key: string, value: string}[]

---@alias zmk.PreviewSymbols { space: string, tl: string, tr: string, bl: string, br: string, horz: string, vert: string, tm: string, bm: string, ml: string, mr: string, mm: string }

---Struct to represent the users desired layout
---@alias zmk.LayoutPlan zmk.LayoutPlanKey[][]

---Struct to represent a single key in a zmk.Layout
---@class zmk.LayoutPlanKey
---@field width number
---@field align? string
---@field type 'key' | 'span' | 'gap'

---------------------------------------------------------------------------------
---- USER CONFIG
---------------------------------------------------------------------------------

---The users config passed to zmk before parsing
---@class zmk.UserConfig
---@field layout zmk.UserLayout
---@field timeout? number # if using nvim-notify, this will be the duration of the notification
---@field auto_format_pattern? string | string[] # autocommand pattern to match against for auto formatting, e.g. '*.keymap'
---@field comment_preview? zmk.UserPreview

---@alias zmk.UserLayout string[]

---@class zmk.UserPreview
---@field position? 'top' | 'bottom' | 'none'
---@field keymap_overrides? table<string, string> # table of keymap overrides, e.g. { ESC = 'Esc' }
---@field symbols? zmk.PreviewSymbols

---@class zmk.InlineConfig
---@field layout? zmk.UserLayout
---@field comment_preview? zmk.UserPreview
