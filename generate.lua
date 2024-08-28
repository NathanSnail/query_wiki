local lfs = require("lfs")
local nxml = require("luanxml.nxml")
local defaults = require("meta.defaults")
nxml.error_handler = function(_, _) end
---@type util
local util = require("util")

---@class (exact) expanded_action: action
---@field shot_state table<string, any>
---@field begun_projectiles string[]

---@class generator
local generator = {
	---@type string
	root = "",
	---@type collection
	files = {},
	---@type table<string, expanded_action>
	spells = {},
	---@type collection
	spell_collection = {},
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
		self.files[k] = v:sub(#self.root + 2)
	end
end

function generator:scan_proj()
	---@type any
	---@diagnostic disable-next-line: lowercase-global
	reflecting = true
	---@diagnostic disable-next-line: lowercase-global
	reflecting = nil
end

---@param path string
---@return string
function generator:get_content(path)
	local cached = self.file_cache[path]
	if cached then
		return cached
	end
	local f = io.open(self.root .. path, "r")
	if not f then
		return ""
	end
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
	local success, res = pcall(nxml.parse, src)
	if not success then
		return nil
	end
	self.xml_cache[path] = res
	return res
end

---@param ex_path string
---@return boolean
function generator:exists(ex_path)
	local f = io.open(self.root .. ex_path, "r")
	if not f then
		return false
	end
	f:close()
	return true
end

---@param path string
---@return element?
function generator:get_entity_xml(path)
	local cached = self.entity_cache[path]
	if cached then
		return cached
	end
	local tree = util.deep_copy(self:get_xml(path))
	if not tree then
		return nil
	end
	if tree.name ~= "Entity" then
		return nil
	end
	tree:expand_base(function(x)
		return self:get_content(x)
	end, function(x)
		return self:exists(x)
	end)
	tree:apply_defaults(defaults)
	self.entity_cache[path] = tree
	return tree
end

---@param callback fun(): ... any
---@return ...
local function no_globals(callback)
	local __G = {}
	for k, v in pairs(_G) do
		__G[k] = v
	end
	local res = { callback() }
	for k, v in __G.pairs(_G) do
		if v ~= _G then
			_G[k] = nil
		end
	end
	for k, v in __G.pairs(__G) do
		_G[k] = v
	end
	return unpack(res)
end

function generator:gen_spells()
	---@type expanded_action[]
	local acts = no_globals(function()
		require("fake_engine")
		dofile("data/scripts/gun/gun.lua")
		local registered = {}
		function Reflection_RegisterProjectile(entity_filename)
			table.insert(registered, entity_filename)
		end
		---@diagnostic disable-next-line: lowercase-global
		reflecting = true
		---@diagnostic disable-next-line: undefined-global
		ConfigGunShotEffects_Init(shot_effects)
		---@diagnostic disable-next-line: undefined-global
		for _, action in ipairs(actions) do
			---@cast action expanded_action
			current_reload_time = 0
			local shot = create_shot(0)
			c = shot.state
			set_current_action(action)
			action.action()
			action.shot_state = c
			action.begun_projectiles = registered
			registered = {}
		end
		---@diagnostic disable-next-line: lowercase-global
		reflecting = false
		---@diagnostic disable-next-line: undefined-global
		return actions
	end)
	for _, v in ipairs(acts) do
		self.spells[v.id] = v
	end
end

---@param root string
---@param qm query_manager
---@return generator
local function construct(root, qm)
	if root:sub(#root) ~= "/" then
		root = root .. "/"
	end
	generator.root = root
	generator:scan_fs()
	generator:gen_spells()
	local spell_collection = {}
	for _, v in pairs(generator.spells) do
		table.insert(spell_collection, v)
	end
	generator.spell_collection = qm.construct_collection(spell_collection)
	generator.files = qm.construct_collection(generator.files)
	return generator
end

return construct
