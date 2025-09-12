_G.SBLT_CUS = {}
SBLT_CUS.path = ModPath

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

function SBLT_CUS:require(path)
	local required_folder = string.format("%s%s%s.lua", SBLT_CUS.path, "Components/", path:lower())
	BLT:RunHookTable(BLT.hook_tables.pre, string.lower(path))
	dofile(required_folder)
	BLT:RunHookTable(BLT.hook_tables.post, string.lower(path))
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
		
		local fix, fixed = string.gsub(str_file, problem.issue, problem.fix)
		local unfix, unfixed = string.gsub(str_file, problem.fix, problem.issue)
		
		if not problem.cause then
			if fixed > 0 and unfixed <= 0 then
				str_file = fix
				changes = true
			end
		elseif problem.cause then
			if unfixed > 0 and fixed <= 0 then
				str_file = unfix
				changes = true
			end
		end
	end

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
			issue = 'if file.FileExists(Application:nice_path(self:GetModImagePath())) then',
			fix = 'if file.FileExists(Application:nice_path(self:GetModImagePath())) and not self:GetModImagePath():find(".png") and not self:GetModImagePath():find(".tga") then',
			cause = SBLT_CUS:game_version(54.7)
		}
	}

	todo["lua/SystemMenuManager.lua"] = {
		{
			issue = 'require("lib/managers/dialogs/SpecializationDialog")',
			fix = '--[[require("lib/managers/dialogs/SpecializationDialog")]]--',
			cause = SBLT_CUS:game_version(16.1)
		}
	}

	todo["req/ui/BLTNotificationsGui.lua"] = {
		{
			issue = 'local page_button = self._buttons_panel:bitmap({',
			fix = [[local page_button = self._buttons_panel:bitmap({
			alpha = 0,]],
			cause = false -- let make sure it is always on
		},
		{
			issue = 'managers.experience:cash_string',
			fix = 'managers.experience:experience_string',
			cause = false -- let make sure it is always on
		}
	}

	todo["req/ui/BLTModsGui.lua"] = {
		{
			issue = 'managers.experience:cash_string',
			fix = 'managers.experience:experience_string',
			cause = false -- let make sure it is always on
		}
	}

	todo["req/BLTUpdate.lua"] = {
		{
			issue = [[if managers.network and managers.network.account and managers.network.account:is_overlay_enabled() then
		managers.network.account:overlay_activate("url", url)]],
			fix = [[if managers.network and managers.network.account and Steam.overlay_activate then
		Steam:overlay_activate("url", url)]],
			cause = SBLT_CUS:game_version(139.193)
		}
	}

	todo["req/supermod/BLTSuperMod.lua"] = {
		{
			issue = 'local xml = blt.parsexml',
			fix = 'local xml = blt and blt.parsexml',
			cause = false -- let make sure it is always on
		}
	}

	todo["req/xaudio/XAudio.lua"] = {
		{
			issue = 'blt',
			fix = '--blt',
			cause = blt
		}
	}

	todo["req/xaudio/XAudioMovement.lua"] = {
		{
			issue = 'local l = blt.xaudio.listener',
			fix = 'local l = blt and blt.xaudio.listener',
			cause = false -- let make sure it is always on
		},
		{
			issue = 'if not blt.xaudio.issetup() then',
			fix = 'if not (blt and blt.xaudio.issetup()) then',
			cause = false -- let make sure it is always on
		}
	}

	todo["req/BLTModManager.lua"] = {
		{
			issue = 'call_on_next_update(callback(self, self, "_RunAutoCheckForUpdates"))',
			fix = 'DelayedCalls:Add("DelayedCall_RunAutoCheckForUpdates", 0, function() self:_RunAutoCheckForUpdates() end)',
			cause = SBLT_CUS:game_version(68.187)
		}
	}

	for file_path, tbl in pairs(todo) do
		change_lines(path .. file_path, tbl)
	end
end

for i, mod in ipairs(BLT.Mods:Mods()) do
	if mod:GetName() == "SuperBLT" then
		fix_sblt(mod:GetPath())
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

if type(call_on_next_update) ~= "function" then
	function call_on_next_update(func, optional_key)
		func()
	end
end