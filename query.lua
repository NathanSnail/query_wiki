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

---@class collection<T>: {[integer]: T, filter: (fun(self: collection<T>, filter: fun(val: T): boolean?): collection<T>), map: (fun(self: collection<T>, new: fun(val: T): any): collection<any>), print: fun(self: collection<T>, prefix: ...?)}
---@type collection<any>
local collection_funcs = {
	filter = query_manager.filter,
	map = query_manager.map,
	print = function(self, ...)
		if ... ~= nil then
			print(..., self)
			return
		end
		print(self)
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
