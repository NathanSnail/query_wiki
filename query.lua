---@class util
local util = require("util")

---@type table<string, fun(key: ...): any?>
local db = {}

---@class query_manager
local query_manager = {}

---@generic T
---@param col string
---@param generator fun(...): T?
function query_manager:add_col(col, generator)
	db[col] = util.single_cached(generator)
end

---@param col string
---@return any?
function query_manager:get(col, ...)
	return db[col](...)
end

---@class set
local set_funcs = {
	filter = function()
		return query_manager.filter
	end,
	get = function(self)
		local v = {}
		for _, elem in ipairs(self) do
			table.insert(v, query_manager:get(elem, v))
		end
		return query_manager.construct_set(v)
	end,
}

local set_mt = {
	__index = set_funcs,
}

---@param set set | any[]
---@return set
function query_manager.construct_set(set)
	return setmetatable(set, set_mt)
end

---@param set set | any[]
---@param filter fun(any): boolean?
---@return set
function query_manager.filter(set, filter)
	local out = setmetatable({}, set_mt)
	for _, e in ipairs(set) do
		if filter(e) then
			table.insert(out, e)
		end
	end
	return out
end

return query_manager