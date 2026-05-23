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

	---@type zmk.LayoutPlan
	local result = {}
	local seen_indexes = {}

	local row_token_counts = {}

	for row_i, row in pairs(layout) do
		check(#row > 0, E.layout_row_empty)

		check(not vim.startswith(row, ' '), E.layout_trailing_whitespace)
		check(not vim.endswith(row, ' '), E.layout_trailing_whitespace)

		---@diagnostic disable-next-line: missing-parameter
		local raw = vim.split(row, ' ', { plain = true })
		local tokens = vim.tbl_filter(function(t)
			return t ~= ''
		end, raw)

		row_token_counts[row_i] = #tokens
		if row_i > 1 then
			check(#tokens == row_token_counts[row_i - 1], E.layout_missing_padding)
		end

		---@type zmk.LayoutPlanKey[]
		local cells = {}
		for col_i, tok in ipairs(tokens) do
			if tok == '_' then
				cells[col_i] = { type = 'gap' }
			else
				check(tok:match('^%d+$'), E.config_invalid_symbol)
				local n = tonumber(tok)
				check(n and n >= 1, E.config_invalid_symbol)
				cells[col_i] = { type = 'key', key_index = n }
			end
		end

		-- coalesce consecutive same key_index into a span
		local i = 1
		while i <= #cells do
			local c = cells[i]
			if c.type == 'key' then
				local j = i
				while
					j + 1 <= #cells
					and cells[j + 1].type ~= 'gap'
					and cells[j + 1].key_index == c.key_index
				do
					j = j + 1
				end
				if j > i then
					for k = i, j do
						cells[k] = { type = 'span', key_index = c.key_index }
					end
				end
				i = j + 1
			else
				i = i + 1
			end
		end

		-- ensure each key_index used in exactly one row (no vertical spans)
		local row_indexes = {}
		for _, c in ipairs(cells) do
			if c.key_index then
				row_indexes[c.key_index] = true
			end
		end
		for idx in pairs(row_indexes) do
			check(not seen_indexes[idx], E.key_index_duplicate(idx))
			seen_indexes[idx] = true
		end

		result[row_i] = cells
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

---@class zmk.Config
---@field timeout number
---@field auto_format_pattern string | string[]
---@field layout zmk.LayoutPlan
---@field comment_preview zmk.Preview

---@class zmk.Preview
---@field position 'top' | 'bottom' | 'none'
---@field keymap_overrides zmk.KeymapList
---@field symbols zmk.PreviewSymbols

---@alias zmk.KeymapList {key: string, value: string}[]

---@alias zmk.PreviewSymbols { space: string, tl: string, tr: string, bl: string, br: string, horz: string, vert: string, tm: string, bm: string, ml: string, mr: string, mm: string }

---@alias zmk.LayoutPlan zmk.LayoutPlanKey[][]

---@class zmk.LayoutPlanKey
---@field type 'key' | 'span' | 'gap'
---@field key_index? number

---------------------------------------------------------------------------------
---- USER CONFIG
---------------------------------------------------------------------------------

---@class zmk.UserConfig
---@field layout zmk.UserLayout
---@field timeout? number
---@field auto_format_pattern? string | string[]
---@field comment_preview? zmk.UserPreview

---@alias zmk.UserLayout string[]

---@class zmk.UserPreview
---@field position? 'top' | 'bottom' | 'none'
---@field keymap_overrides? table<string, string>
---@field symbols? zmk.PreviewSymbols

---@class zmk.InlineConfig
---@field layout? zmk.UserLayout
---@field comment_preview? zmk.UserPreview
