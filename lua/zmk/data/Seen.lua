---@class zmk.Seen
---@field private index zmk.SeenIndex
local Seen = {}

---Create a new Seen instance
---@return zmk.Seen
function Seen:new()
	local me = { index = {} }
	self.__index = self
	return setmetatable(me, self)
end

---increment
---@param cell zmk.LayoutGridCell
---@param ctx zmk.LayoutGridContext
function Seen:increment(cell, ctx)
	local seen = self.index[cell.key_index] or { span = 0 }
	self.index[cell.key_index] = {
		span = seen.span + cell.span,
		count = (seen.count or 0) + 1,
		is_last = not ctx.is_bridge_vert,
	}
end

---Get stuff
---@param key_index number
---@return zmk.SeenSpan | nil
function Seen:get(key_index)
	return self.index[key_index]
end

return Seen

---@alias zmk.SeenIndex table<number, zmk.SeenSpan>

---@class zmk.SeenSpan
---@field span number
---@field is_last boolean
---@field count number
