---@class util
local util = {}

---@generic T
---@param src T
---@param cache table<{}, {}>
---@return T
local function internal_deep_copy(src, cache)
	if type(src) ~= "table" then
		return src
	end
	if cache[src] then
		return cache[src]
	end
	local mt = getmetatable(src)
	local new = setmetatable({}, mt)
	cache[src] = new
	for k, _ in pairs(src) do -- maybe an issue with pairs idk
		rawset(new, k, internal_deep_copy(rawget(src, k), cache))
	end
	return new
end

---@generic T
---@param src T
---@return T
function util.deep_copy(src)
	return internal_deep_copy(src, {})
end

---Doesn't cache nils
---@generic T
---@param fn fun(...): T
---@return fun(...): T
function util.many_cached(fn)
	local cache = {}
	return function(...)
		local args = { ... }
		local cur_cache = cache
		for k, v in ipairs(args) do
			if not cur_cache or not cur_cache[v] then
				break
			end
			if k == #args then
				return cur_cache[v]
			end
			cur_cache = cur_cache[v]
		end

		local res = fn(...)
		cur_cache = cache
		for k, v in ipairs(args) do
			cur_cache[v] = cur_cache[v] or {}
			if k == #args then
				cur_cache[v] = res
			else
				cur_cache = cur_cache[v]
			end
		end
		return res
	end
end

return util
