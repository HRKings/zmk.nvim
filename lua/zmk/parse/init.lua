local E = require('zmk.errors')
local check = require('zmk.utils').check
local merge_configs = require('zmk.config.merge')

local M = {
	zmk = require('zmk.parse.zmk'),
}

---assert all keymaps don't overlap with the declaration itself
---@param keymaps zmk.Keymaps
---@throws string
local function validate(keymaps)
	local start, final = keymaps.pos.start, keymaps.pos.final

	check(#keymaps.keymaps > 0, E.keymaps_none)

	-- iterate over all keymaps
	for _, keymap in pairs(keymaps.keymaps) do
		local keymap_start, keymap_final = keymap.pos.start, keymap.pos.final
		check(keymap_start > start, E.keymaps_overlap)
		check(keymap_final < final, E.keymaps_overlap)

		check(#keymap.keys > 0, E.keymap_empty(keymap.layer_name))
	end
end

---parse a keymap file into a zmk.Keymaps struct
---@param content string
---@param options zmk.Config
---@param parser fun(content: string, options: zmk.Config): zmk.Keymaps, zmk.InlineConfig | nil
---@return zmk.Keymaps, zmk.Config
function M.parse(content, options, parser)
	local keymaps, inline_config = parser(content, options)
	validate(keymaps)
	local final_config = inline_config and merge_configs(options, inline_config) or options

	return keymaps, final_config
end

return M

--------------------------------------------------------------------------------
-- TYPES
--------------------------------------------------------------------------------

---@class zmk.Keymaps
---@field keymaps zmk.KeymapsList
---@field pos zmk.Position

---@alias zmk.KeymapsList zmk.Keymap[]

---@class zmk.Keymap
---@field layer_name string
---@field layout_name string
---@field keys string[]
---@field pos zmk.Position

---@class zmk.Position
---@field start number
---@field final number
