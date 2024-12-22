function table.map_append(t, ...)
	for _, list_table in ipairs({
		...
	}) do
		for key, value in pairs(list_table) do
			t[key] = value
		end
	end

	return t
end

function table.set(...)
	return table.list_to_set({
		...
	})
end

function table.list_to_set(list)
	local rtn = {}

	for _, v in pairs(list) do
		rtn[v] = true
	end

	return rtn
end