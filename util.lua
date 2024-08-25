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
		local new = {}
		new = setmetatable(new, mt)
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

return util
