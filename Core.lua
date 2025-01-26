local SBLT_CUS_path = ModPath

function version_number()
	local ver = Application:version()
	if ver == "Tournament" then
		ver = "1.54.12"
	end
	
	return tonumber(ver:sub(3, #ver))
end

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

local function change_lines(path, problems)
	local file = io.open(path, 'r')
	if not file or not problems or not #problems == 0 then
		return
	end

	local changes = false
	local strings = {}
	local str_file = ""
	for line in file:lines() do
		str_file = str_file .. line .. '\n'
	end
	file:close()
	
	for _, problem in pairs(problems) do
		problem.fix = problem.fix:gsub("%p", function(s) return '%' .. s end)
		problem.issue = problem.issue:gsub("%p", function(s) return '%' .. s end)

		if not problem.cause and not str_file:find(problem.fix) then
			str_file = str_file:gsub(problem.issue, problem.fix)
			changes = true
		elseif problem.cause and str_file:find(problem.fix) then
			str_file = str_file:gsub(problem.fix, problem.issue)
			changes = true
		end
	end

	-- SaveTable(str_file, "lox.txt")
	if changes then
		file = io.open(path, 'w')
		file:write(str_file)
		file:close()
	end
end

local function fix_sblt(path)
	local todo = {}
	todo["req/BLTMod.lua"] = {
		{
			issue = 'self:GetPath() .. tostring(self.image_path)',
			fix = 'self:GetPath() .. tostring(self.image_path:gsub(".png", ""))',
			cause = version_number() >= 54.7
		}
	}
	
	for file_path, tbl in pairs(todo) do
		change_lines(path .. file_path, tbl)
	end
end

local function fix_beardlib(path)
	local todo = {}
	
	todo["main.xml"] = {
		{
			issue = '<unit path="core/units/run_sequence_dummy/run_sequence_dummy"/>',
			fix = '<!-- <unit path="core/units/run_sequence_dummy/run_sequence_dummy"/> -->',
			cause = false --need to find out which version doesn't crash with this
		}
	}

	todo["Classes/Frameworks.lua"] = {
		{
			issue = 'self:FindAlreadyOverriden',
			fix = '-- self:FindAlreadyOverriden',
			cause = version_number() >= 16.5
		}
	}
	
	todo["Classes/Managers/FileManager.lua"] = {
		{
			issue = 'Application:reload_textures',
			fix = '-- Application:reload_textures',
			cause = version_number() >= 54.7
		},
		{
			issue = 'blt.wren_io',
			fix = '-- blt.wren_io',
			cause = blt and blt.wren_io
		}
	}

	todo["Classes/Managers/PackageManager.lua"] = {
		{
			issue = 'BeardLibPackageManager.EXT_CONVERT = {dds = "texture", png = "texture", tga = "texture", jpg = "texture", bik = "movie"}',
			fix = 'BeardLibPackageManager.EXT_CONVERT = {dds = "texture", png = "", tga = "", jpg = "", bik = "movie"}',
			cause = version_number() >= 54.7
		}
	}

	todo["Classes/WeaponSkinExtension.lua"] = {
		{
			issue = 'require',
			fix = '-- require',
			cause = version_number() >= 54.7
		}
	}

	todo["Hooks/Items/PlayerStyleGloveHooks.lua"] = {
		{
			issue = 'local F',
			fix = '-- local F',
			cause = version_number() >= 95.894
		}
	}

	todo["Hooks/Items/NetworkPeer.lua"] = {
		{
			issue = 'self:beardlib_reload_outfit',
			fix = '-- self:beardlib_reload_outfit',
			cause = version_number() >= 93.844
		}
	}

	todo["Hooks/Items/NetworkHooks.lua"] = {
		{
			issue = 'peer:beardlib_reload_outfit',
			fix = '-- peer:beardlib_reload_outfit',
			cause = version_number() >= 93.844
		}
	}
	
	todo["Modules/PD2/LevelModule.lua"] = {
		{
			issue = 'l_self.ai_groups[self._config.ai_group_type] or l_self.ai_groups.default',
			fix = '"america"',
			cause = version_number() >= 50.0
		}
	}

	todo["Modules/PD2/NarrativeModule.lua"] = {
		{
			issue = 'narr_self.stages[stage.level_id] = stage',
			fix = [[if narr_self.stages then
					narr_self.stages[stage.level_id] = stage
				end]],
			cause = version_number() >= 65.0
		},
		{
			issue = 'narr_self.stages[_stage.level_id] = _stage',
			fix = [[if narr_self.stages then
						narr_self.stages[_stage.level_id] = _stage
					end]],
			cause = version_number() >= 65.0
		}
	}

	todo["Hooks/Maps/NetworkHooks.lua"] = {
		{
			issue = 'managers.job:current_world_setting()',
			fix = 'nil',
			cause = version_number() >= 12.1
		}
	}

	todo["Hooks/Maps/Hooks.lua"] = {
		{
			issue = 'KillzoneManager.type_upd_funcs.kill = function (obj, t, dt, data)',
			fix = [[KillzoneManager.type_upd_funcs = {}
	KillzoneManager.type_upd_funcs.kill = function (obj, t, dt, data)]],
			cause = version_number() >= 136.173
		}
	}

	for file_path, tbl in pairs(todo) do
		change_lines(path .. file_path, tbl)
	end
end

for i, mod in ipairs(BLT.Mods:Mods()) do
	if mod:GetName() == "SuperBLT" then
		fix_sblt(mod:GetPath())
	elseif mod:GetName() == "BeardLib" then
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