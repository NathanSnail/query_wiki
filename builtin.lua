---@param qm query_manager
---@param gen generator
local function builtin(qm, gen)
	qm:add_col("name", function(path)
		local ex = gen:get_entity_xml(path)
		if ex then
			return ex:get("name")
		end
	end)
	qm:add_col("dmc", function(path)
		local ex = gen:get_entity_xml(path)
		if ex then
			return ex:first_of("DamageModelComponent")
		end
	end)
	qm:add_col("comp", function(path, comp)
		local ex = gen:get_entity_xml(path)
		if ex then
			return ex:first_of(comp)
		end
	end)
	qm:add_col("field", function(path, comp, field)
		local ex = qm:get("comp", path, comp)
		if ex then
			return ex:get(field)
		end
	end)
	qm:add_col("hp", function(path)
		---@type element?
		local elem = qm:get("dmc", path)
		if elem then
			return elem:get("hp")
		end
	end)
end

return builtin
