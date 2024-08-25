---@class util
local util = {}

---@generic T
---@param src T
---@param cache table<{}, {}>
---@return any
local function internal_depp_copy(src, cache)
	if type(src) == "table" then
		if cache[src] then
			return cache[src]
		end
		local mt = getmetatable(src)
		local new = setmetatable({}, mt)
		cache[src] = new
		for k, _ in pairs(src) do -- maybe an issue with pairs idk
			rawset(new, k, internal_depp_copy(rawget(src, k), cache))
		end
		return new
	end
	return src
end

---@generic T
---@param src T
---@return T
function util.deep_copy(src)
	return internal_depp_copy(src, {})
end

---@generic T
---@generic U
---@param fn fun(key: T): U
---@return fun(key: T): U
function util.single_cached(fn)
	local cache = {}
	return function(arg)
		if cache[arg] then
			return cache[arg]
		end
		return fn(arg)
	end
end

return util
