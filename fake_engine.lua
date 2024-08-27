local M = {}
package.path = package.path .. ";" .. "/home/nathan/Documents/code/noitadata/data/" .. "?.lua;" 
local _print = print
require("meta.api")
print = _print

local socket = require("socket")
local frame = math.floor(socket.gettime() * 1000) % 2 ^ 16
function Random(a, b)
	if not a and not b then
		return math.random()
	end
	if not b then
		b = a
		a = 0
	end
	return math.floor(math.random() * (b - a + 1)) + a
end

local globals = {}
local append_map = {}

function GlobalsSetValue(key, value)
	globals[key] = tostring(value)
end

function ModTextFileGetContent(filename)
	local success, res = pcall(function()
		if M.vfs[filename] then
			return M.vfs[filename]
		end
		if filename:sub(1, 4) == "mods" then
			return assert(assert(io.open(M.mods_path .. filename)):read("*a"))
		end
		return assert(assert(io.open(M.data_path .. filename)):read("*a"))
	end)
	if not success then
		return ""
	end
	return res
end

function ModTextFileSetContent(filename, new_content)
	M.vfs[filename] = new_content
end

function GlobalsGetValue(key, value)
	return tostring(globals[key] or value)
end

function SetRandomSeed(x, y)
	math.randomseed(x * 591.321 + y * 8541.123 + 124.545)
end

function GameGetFrameNum()
	return frame
end

function ModLuaFileAppend(to, from)
	append_map[to] = append_map[to] or {}
	table.insert(append_map[to], from)
end

function dofile(file)
	local res = { require(file:sub(1, file:len() - 4)) }
	for _, v in ipairs(append_map[file] or {}) do
		dofile(v)
	end
	return unpack(res)
end
dofile_once = dofile
return M
