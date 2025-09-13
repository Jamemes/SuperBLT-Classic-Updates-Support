function table.deep_map_copy(map)
	local copy = {}

	for k, v in pairs(map) do
		if type(v) == "table" then
			copy[k] = table.deep_map_copy(v)
		else
			copy[k] = v
		end
	end

	return copy
end

function table.contains_any(v, e)
	for _, value in pairs(v) do
		for _, element in ipairs(e) do
			if value == element then
				return true
			end
		end
	end

	return false
end

function table.contains_all(v, e)
	for _, element in ipairs(e) do
		local element_found = false

		for _, value in pairs(v) do
			if value == element then
				element_found = true

				break
			end
		end

		if not element_found then
			return false
		end
	end

	return true
end

function table.contains_only(v, e)
	return table.contains_all(e, v)
end

function table.count(v, func)
	local i = 0

	for k, item in pairs(v) do
		if func(item, k) then
			i = i + 1
		end
	end

	return i
end

function table.crop(t, size)
	while t[size + 1] do
		table.remove(t, size + 1)
	end
end

function table.random_key(t)
	if not next(t) then
		return
	end

	local rand_nr = math.random(table.size(t))
	local key = nil

	for i = 1, rand_nr do
		key = next(t, key)
	end

	return key
end

function table.shuffled_copy(t)
	if #t == 0 then
		return {}
	end

	local shuffled_copy = clone(t)

	for i = 1, #shuffled_copy - 1 do
		local swap_index = math.random(i, #shuffled_copy)
		local temp = shuffled_copy[i]
		shuffled_copy[i] = shuffled_copy[swap_index]
		shuffled_copy[swap_index] = temp
	end

	return shuffled_copy
end

function table.shuffle(t)
	for i = 1, #t - 1 do
		local swap_index = math.random(i, #t)
		local temp = t[i]
		t[i] = t[swap_index]
		t[swap_index] = temp
	end
end

function table.find_value(t, func)
	for k, value in ipairs(t) do
		if func(value) then
			return value, k
		end
	end
end

function table.filter(t, func)
	local res = {}

	for key, value in pairs(t) do
		if func(value, key) then
			res[key] = value
		end
	end

	return res
end

function table.filter_list(t, func)
	local res = {}

	for _, value in pairs(t) do
		if func(value) then
			table.insert(res, value)
		end
	end

	return res
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

function table.list_reverse(list)
	local copy = {}
	local size = #list

	for k, v in ipairs(list) do
		copy[size - k + 1] = v
	end

	return copy
end

function table.reverse_ipairs(t)
	local i = #t + 1

	return function ()
		i = i - 1

		if i == 0 then
			return
		end

		return i, t[i]
	end
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

function table.is_list_value_union(list1, list2)
	for _, value1 in ipairs(list1) do
		for _, value2 in ipairs(list2) do
			if value1 == value2 then
				return true
			end
		end
	end

	return false
end

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

function table.lower_bound(t, target, func)
	func = func or function (a, b)
		return a < b
	end

	for k, v in ipairs(t) do
		if not func(v, target) then
			return v, k
		end
	end
end

function table.upper_bound(t, target, func)
	func = func or function (a, b)
		return a < b
	end

	for k, v in ipairs(t) do
		if func(target, v) then
			return v, k
		end
	end
end

local default_unpack = default_unpack or unpack
function _G.unpack(t, i, n)
	if i == nil and n == nil then
		return default_unpack(t, 1, table.maxn(t))
	elseif n == nil then
		return default_unpack(t, i, table.maxn(t))
	end

	return default_unpack(t, i, n)
end
