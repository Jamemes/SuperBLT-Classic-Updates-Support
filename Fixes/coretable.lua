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

function table.remove_condition(t, func)
	local i = 1

	while next(t) and i <= #t do
		if func(t[i]) then
			table.remove(t, i)
		else
			i = i + 1
		end
	end
end