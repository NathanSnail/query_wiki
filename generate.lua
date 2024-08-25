local lfs = require("lfs")
local nxml = require("luanxml.nxml")
---@type util
local util = require("util")

---@class generator
local generator = {
	---@type string
	root = "",
	---@type string[]
	files = {},
	---@type table<string, string>
	file_cache = {},
	---@type table<string, element>
	xml_cache = {},
	---@type table<string, element>
	entity_cache = {},
	---@type table<string, element>
	material_cache = {},
}

---Initialises the generator with the root as fs
function generator:scan_fs()
	local files = {}
	local to_search = { self.root }
	while #to_search ~= 0 do
		local choice = to_search[#to_search]
		to_search[#to_search] = nil
		local iter, dir_obj = lfs.dir(choice)
		while true do
			local f = iter(dir_obj)
			if f == nil then
				break
			end
			if f:sub(1, 1) == "." then
				goto continue
			end
			f = choice .. "/" .. f
			local ty = lfs.attributes(f, "mode")
			if ty == "directory" then
				to_search[#to_search + 1] = f
			else
				table.insert(files, f)
			end
			::continue::
		end
	end
	for k, v in ipairs(files) do
		self.files[k] = v:sub(#self.root)
	end
end

---@param path string
---@return string
function generator:get_content(path)
	local cached = self.file_cache[path]
	if cached then
		return cached
	end
	local f = assert(io.open(self.root .. path, "r"))
	local res = f:read("a")
	f:close()
	self.file_cache[path] = res
	return res
end

---@param path string
---@return element?
function generator:get_xml(path)
	if path:sub(#path - 3) ~= ".xml" then
		return nil
	end
	local cached = self.xml_cache[path]
	if cached then
		return cached
	end
	local src = self:get_content(path)
	local res = nxml.parse(src)
	self.xml_cache[path] = res
	return res
end

---@param path string
---@return element?
function generator:get_entity_xml(path)
	local cached = self.entity_cache[path]
	if cached then
		return cached
	end
	local tree = util.deep_copy(self:get_xml(path))
	if not tree then return nil end
	tree:expand_base(function(x)
		return self:get_content(x)
	end)
	self.entity_cache[path] = tree
	return tree
end

return function(root)
	if root:sub(#root) ~= "/" then
		root = root .. "/"
	end
	generator.root = root
	generator:scan_fs()
	return generator
end
