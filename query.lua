---@class util
local util = require("util")

---@type table<string, fun(...: any): any?>
local db = {}

---@class query_manager
local query_manager = {}

---@generic T
---@param col string
---@param generator fun(...: any): T?
function query_manager:add_col(col, generator)
	db[col] = util.many_cached(generator)
end

---@param col string
---@param ... any
---@return any?
function query_manager:get(col, ...)
	return db[col](...)
end
--Nasty forward declare, collection_mt requires collection_mt:filter requires qm.filter require collection_mt
local collection_mt

---@param collection collection | any[]
---@return collection
function query_manager.construct_collection(collection)
	return setmetatable(collection, collection_mt)
end

---@param collection collection
---@param filter fun(any): boolean?
---@return collection
function query_manager.filter(collection, filter)
	local out = setmetatable({}, collection_mt)
	for _, e in ipairs(collection) do
		local ok, res = pcall(filter, e)
		if ok and res then
			table.insert(out, e)
		end
	end
	return out
end

---@param collection collection
---@param new fun(any): any
---@return collection
function query_manager.map(collection, new)
	local out = setmetatable({}, collection_mt)
	for _, e in ipairs(collection) do
		local ok, res = pcall(new, e)
		if ok then
			table.insert(out, res)
		end
	end
	return out
end

---@class collection
local collection_funcs = {
	filter = query_manager.filter,
	map = query_manager.map,
	print = print,
	get = function(self)
		local v = {}
		for _, elem in ipairs(self) do
			table.insert(v, query_manager:get(elem, v))
		end
		return query_manager.construct_collection(v)
	end,
}

collection_mt = {
	__index = collection_funcs,
	__tostring = function(self)
		local s = ""
		for k, v in ipairs(self) do
			s = s .. v .. (k == #self and "" or ", ")
		end
		return s
	end,
}

return query_manager
