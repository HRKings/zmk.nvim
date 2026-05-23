local generate = require('zmk.format.preview').generate
local LayoutGrid = require('zmk.data.LayoutGrid')
local get_key_text = require('zmk.format.get_key_text')
local utils = require('zmk.utils')

---Render source bindings in sequential index order (1..N), splitting into lines
---using the layout's per-row key counts. Whitespace is normalised so each key
---in a column is padded to the widest key in that source row column. The source
---ordering is independent of the visual layout positions so format is idempotent
---even when layout indices are spread across rows.
---@param keys string[]
---@param layout zmk.LayoutPlan
---@return string[]
local function render_source(keys, layout)
	local row_counts = {}
	for _, row in ipairs(layout) do
		local n = 0
		for _, cell in ipairs(row) do
			if cell.type == 'key' or cell.type == 'span' then
				n = n + 1
			end
		end
		row_counts[#row_counts + 1] = n
	end

	---@type string[][]
	local rows = {}
	local idx = 1
	for r, count in ipairs(row_counts) do
		rows[r] = {}
		for _ = 1, count do
			if keys[idx] then
				table.insert(rows[r], keys[idx])
			end
			idx = idx + 1
		end
	end

	-- column widths: max width per column across all rows that have a key there
	local max_cols = 0
	for _, row in ipairs(rows) do
		if #row > max_cols then
			max_cols = #row
		end
	end
	local col_widths = {}
	for c = 1, max_cols do
		local w = 0
		for _, row in ipairs(rows) do
			if row[c] then
				local len = utils.len(row[c])
				if len > w then
					w = len
				end
			end
		end
		col_widths[c] = w
	end

	local out = {}
	for _, row in ipairs(rows) do
		local parts = { '  ' }
		for c, key in ipairs(row) do
			local pad = col_widths[c] - utils.len(key)
			local is_last = c == #row
			table.insert(parts, key)
			if not is_last then
				table.insert(parts, string.rep(' ', pad) .. '   ')
			end
		end
		out[#out + 1] = (table.concat(parts)):gsub(' +$', '')
	end
	return out
end

---@param options zmk.Config
---@param keymap zmk.Keymap
---@return zmk.ZMKResult
local function format_keymap(keymap, options)
	local keys = keymap.keys
	local comment_preview = options.comment_preview

	local preview_layout = LayoutGrid:new(
		options.layout,
		vim.tbl_map(get_key_text(comment_preview.keymap_overrides), keys)
	)
	local preview = comment_preview.position ~= 'none'
			and generate(preview_layout, comment_preview.symbols)
		or nil

	return {
		layer_name = keymap.layer_name,
		pos = keymap.pos,
		keys = render_source(keys, options.layout),
		preview = preview and vim.tbl_map(table.concat, preview) or nil,
	}
end

return format_keymap

---@class zmk.ZMKResult
---@field layer_name string
---@field pos zmk.Position
---@field keys string[]
---@field preview? string[]
