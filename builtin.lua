---@param qm query_manager
---@param gen generator
local function builtin(qm, gen)
	qm:add_col("name", function(path)
		return gen:get_entity_xml(path):get("name")
	end)
	qm:add_col("dmc", function(path)
		return gen:get_entity_xml(path):first_of("DamageModelComponent")
	end)
	qm:add_col("comp", function(path, comp)
		return gen:get_entity_xml(path):first_of(comp)
	end)
	qm:add_col("field", function(path, comp, field)
		local c = gen:get_entity_xml(path):first_of(comp)
		if c then
			return c:get(field)
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
