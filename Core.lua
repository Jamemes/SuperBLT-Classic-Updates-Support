_G.SBLT_CUS = {}
SBLT_CUS.path = ModPath

if not (blt and blt.db_create_entry) then
	if not os.rename("mods/saves", "mods/saves") then
		log('creating "mods/saves"')
		os.execute('mkdir "mods/saves"')
	end
		 
	if not os.rename("mods/downloads", "mods/downloads") then
		log('creating "mods/downloads"')
		os.execute('mkdir "mods/downloads"')
	end

	if not os.rename("mods/logs", "mods/logs") then
		log('creating "mods/logs"')
		os.execute('mkdir "mods/logs"')
	end
end

function SBLT_CUS:game_version(param)
	local ver = ""
	local ver_file = io.open("game.ver", 'r')
	if not ver_file then
		return "0.0.0"
	end
	
	for line in ver_file:lines() do
		ver = line
	end
	ver_file:close()
	
	if param then
		if type(param) == "number" then
			if ver == "Tournament" then
				ver = "1.54.12"
			end
			return tonumber(ver:sub(3, #ver)) >= param
		elseif param == "num" then
			return tonumber(ver:sub(3, #ver))
		end
	else
		return ver
	end
end

local components_directories = {}
local required_folder = SBLT_CUS.path .. "Components/"
local function collect_directories(path, previous)
	for _, folder in pairs(path) do
		local directory = previous .. folder .. "/"
		for _, f in pairs(file.GetFiles(directory)) do
			local file_directory = directory .. f
			local clear_path = file_directory:sub(#required_folder + 1, #file_directory - 4):lower()
			table.insert(components_directories, clear_path)
		end
	
		collect_directories(file.GetDirectories(directory), directory)
	end
end

collect_directories(file.GetDirectories(required_folder), required_folder)

local function contains(v, e)
	for _, value in pairs(v) do
		if value == e then
			return true
		end
	end
	return false
end
  
function SBLT_CUS:OverrideRequire()
	if self.require then
		return false
	end

	-- Cache original require function
	self.require = _G.require

	-- Override require function to run hooks
	_G.require = function(...)
		local args = { ... }
		local path = args[1]
		local path_lower = path:lower()
		local require_result = nil
		if contains(components_directories, path_lower) then
			BLT:RunHookTable(BLT.hook_tables.pre, path_lower)
			require_result = dofile(required_folder .. path_lower .. ".lua")
			BLT:RunHookTable(BLT.hook_tables.post, path_lower)

			for k, v in ipairs(BLT.hook_tables.wildcards) do
				BLT:RunHookFile(path, v)
			end
		else
			require_result = self.require(...)
		end

		return require_result
	end
end

SBLT_CUS:OverrideRequire()

if type(file.FileExists) ~= "function" then
	function file.FileExists(path)
		return os.rename(path, path)
	end
end

if type(file.DirectoryExists) ~= "function" then
	function file.DirectoryExists(path)
		return os.rename(path, path)
	end
end

if type(file.MoveDirectory) ~= "function" then
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

if type(call_on_next_update) ~= "function" then
	function call_on_next_update(func, optional_key)
		func()
	end
end