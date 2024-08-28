---@diagnostic disable: need-check-nil
---@param qm query_manager
---@param gen generator
local function builtin(qm, gen)
	qm:add_col("name", function(path)
		local xml = gen:get_entity_xml(path)
		return xml:get("name")
	end)
	qm:add_col("comp", function(path, comp)
		local xml = gen:get_entity_xml(path)
		return xml:first_of(comp)
	end)
	qm:add_col("field", function(path, comp, field)
		local xml = qm:get("comp", path, comp)
		return xml:get(field)
	end)
end

return builtin
