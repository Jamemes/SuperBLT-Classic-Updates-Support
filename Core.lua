local SBLT_CUS_path = ModPath
local components_directories = {}
local required_folder = SBLT_CUS_path .. "Components/"
function collect_files_pathes(path, previous)
	for _, folder in pairs(path) do
		local directory = previous .. folder .. "/"
		for _, f in pairs(file.GetFiles(directory)) do
			local file_directory = directory .. f
			local clear_path = file_directory:sub(#required_folder + 1, #file_directory - 4)
			table.insert(components_directories, clear_path)
		end
	
		collect_files_pathes(file.GetDirectories(directory), directory)
	end
end

collect_files_pathes(file.GetDirectories(required_folder), required_folder)

local req = require
function require(...)
	if blt == nil then
		blt = setmetatable({}, {})
	end
	
	local param = {...}
	for k, path in pairs(components_directories) do
		if string.lower(param[1]) == string.lower(path) then
			BLT:RunHookTable(BLT.hook_tables.pre, string.lower(param[1]))
			dofile(required_folder .. string.lower(param[1]) .. ".lua")
			BLT:RunHookTable(BLT.hook_tables.post, string.lower(param[1])) 
			
			return
		end
	end

	return req(...)
end

local function change_lines(path, problems, replacement)
	local file = io.open(path, 'r')
	if not file or not problems or not #problems == 0 then
		return
	end
	
	local changes = false
	local strings = {}
	for line in file:lines() do
		for _, problem in pairs(problems) do
			if not problem.cause then
				if not replacement then
					if string.find(line, problem.str) and not string.find(line, [[causes crashes]]) then
						line = "--causes crashes" .. line
						changes = true
					end
				else
					if string.find(line, problem.str) then
						line = line:gsub(problem.str, replacement)
						changes = true
					end
				end
			end
		end

		table.insert(strings, line)
	end
	file:close()
	
	if changes then
		file = io.open(path, 'w')
		for index, value in ipairs(strings) do
			file:write(value .. '\n')
		end
		file:close()
	end
end

local function fix_beardlib(path)
	local todo = {}
	todo["Classes/Managers/FileManager.lua"] = {
		{
			str = 'Application:reload_textures',
			cause = Application.reload_textures
		},
		{
			str = 'blt.wren_io',
			cause = blt and blt.wren_io
		}
	}
	
	todo["Classes/Frameworks.lua"] = {
		{
			str = 'self:FindAlreadyOverriden()',
			cause = DB.mods
		}
	}
	
	todo["Hooks/Items/PlayerStyleGloveHooks.lua"] = {
		{
			str = '',
			cause = false -- change
		}
	}

	for file_path, tbl in pairs(todo) do
		change_lines(path .. file_path, tbl)
	end
end

for i, mod in ipairs(BLT.Mods:Mods()) do
	if mod:GetName() == "BeardLib" then
		fix_beardlib(mod:GetPath())
	end
end

if not file.FileExists then
	function file.FileExists(path)
		return os.rename(path, path)
	end
end

if not file.DirectoryExists then
	function file.DirectoryExists(path)
		return os.rename(path, path)
	end
end

if not file.MoveDirectory then
	function file.MoveDirectory(prev, path)
		local download_name = ""
		local mod_name = ""
		local download_path = string.split(prev, [[\]])
		local mod_path = string.split(path, [[\]])
		
		for k, v in pairs(download_path) do
			download_name = v
		end
		
		for k, v in pairs(mod_path) do
			mod_name = v
		end

		if download_name ~= mod_name then
			local new_path = deep_clone(mod_path)
			new_path[table.size(new_path)] = download_name
			new_path = table.concat(new_path, [[\]])

			os.execute("rd /s /q " .. path)
			os.rename(prev, new_path)

			return os.rename(new_path, path)
		end
		
		return os.rename(prev, path)
	end
end

local data = unzip
unzip = function(path1, path2)
	os.execute("mkdir " .. path2)
	data(path1, path2)
end

local data = dohttpreq
dohttpreq = function(path, func)
	override = function(...)
		local params = {...}
		if not params[3] then
			params[3] = {querySucceeded = true}
		end
		
		return func(params[1], params[2], params[3])
	end
	
	return data(path, override)
end

if not call_on_next_update then
	function call_on_next_update(func, optional_key)
		func()
	end
end