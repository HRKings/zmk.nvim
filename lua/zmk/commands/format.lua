local parser = require('zmk.parse')
local api = vim.api

---@param options zmk.Config
---@param content string[]
---@param bufnr number
---@param last_keymap? number
local function zmk(options, content, bufnr, last_keymap)
	local keymap_id = last_keymap or 1
	local keymaps = parser.parse(table.concat(content, '\n'), options, parser.zmk).keymaps

	local keymap = keymaps[keymap_id]
	if keymap ~= nil then
		local out = require('zmk.format.zmk')(keymap, options)
		if not out.preview then
			api.nvim_buf_set_lines(bufnr, out.pos.start + 1, out.pos.final, false, out.keys)
		elseif options.comment_preview.position == 'bottom' then
			vim.list_extend(out.keys, out.preview)
			api.nvim_buf_set_lines(bufnr, out.pos.start + 1, out.pos.final, false, out.keys)
		else
			vim.list_extend(out.preview, out.keys)
			api.nvim_buf_set_lines(bufnr, out.pos.start + 1, out.pos.final, false, out.preview)
		end

		-- we just reparse over and over till all keymaps are done
		local new_content = api.nvim_buf_get_lines(bufnr, 0, -1, false)
		zmk(options, new_content, bufnr, keymap_id + 1)
	end
end

---format ZMK keymaps in a buffer
---@param options zmk.Config
---@param buf? number
local function format_zmk_keymaps(options, buf)
	local bufnr = buf or api.nvim_get_current_buf()
	local content = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	zmk(options, content, bufnr)
end

return format_zmk_keymaps
