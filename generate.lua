local lfs = require("lfs")

local files = {}
local to_search = { "/home/nathan/Documents/code/noitadata/data" }
while #to_search ~= 0 do
	local choice = to_search[#to_search]
	to_search[#to_search] = nil
	local iter, dir_obj = lfs.dir(choice)
	print("C:", choice)
	while true do
		local f = iter(dir_obj)
		print(f)
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
for _, v in ipairs(files) do
	print(v)
end
print(#files)
