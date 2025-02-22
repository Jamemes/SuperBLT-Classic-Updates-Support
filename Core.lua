local SBLT_CUS_path = ModPath

function game_version(param)
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
			cause = game_version(54.7)
		}
	}

	todo["lua/SystemMenuManager.lua"] = {
		{
			issue = 'require',
			fix = '-- require',
			cause = game_version(16.1)
		}
	}
	
	todo["req/ui/BLTNotificationsGui.lua"] = {
		{
			issue = 'local page_button = self._buttons_panel:bitmap({',
			fix = [[local page_button = self._buttons_panel:bitmap({
			alpha = 0,]],
			cause = DB:has(Idstring("texture"), Idstring("guis/textures/pd2/ad_spot"))
		},
		{
			issue = 'managers.experience:cash_string(pending_downloads_count, "")',
			fix = 'managers.experience:cash_string(pending_downloads_count, ""):gsub("%$", "")',
			cause = game_version(74.278)
		}
	}
	
	todo["req/ui/BLTModsGui.lua"] = {
		{
			issue = 'title = title_text',
			fix = 'title = title_text:gsub("%$", "")',
			cause = game_version(74.278)
		}
	}

	todo["req/BLTUpdate.lua"] = {
		{
			issue = [[if managers.network and managers.network.account and managers.network.account:is_overlay_enabled() then
		managers.network.account:overlay_activate("url", url)]],
			fix = [[if managers.network and managers.network.account and Steam.overlay_activate then
		Steam:overlay_activate("url", url)]],
			cause = game_version(139.193)
		}
	}

	todo["req/supermod/BLTSuperMod.lua"] = {
		{
			issue = 'local xml = blt.parsexml',
			fix = 'local xml = blt and blt.parsexml',
			cause = blt and blt.parsexml
		}
	}

	todo["req/xaudio/XAudio.lua"] = {
		{
			issue = 'blt',
			fix = '--blt',
			cause = blt
		}
	}

	todo["req/ui/BLTNotificationsGui.lua"] = {
		{
			issue = [[self._downloads_panel =self._panel:panel({
		name = "downloads",
		w = 48,
		h = 48,
		layer = 100
	})

	local texture, rect = tweak_data.hud_icons:get_icon_data("csb_throwables")
	self._downloads_panel:bitmap({
		texture = texture,
		texture_rect = rect,
		w = self._downloads_panel:w(),
		h = self._downloads_panel:h(),
		color = Color.red
	})
	self._downloads_panel:rect({
		x = 38 / 2.5 - 2,
		y = 28 / 2.5,
		w = 54 / 2.5,
		h = 72 / 2.5 - 2,
		color = Color.red
	})]],
			fix = [[self._downloads_panel =self._panel:panel({
		name = "downloads",
		w = 38,
		h = 38,
		layer = 100
	})

	self._downloads_panel:bitmap({
		texture = "guis/textures/pd2/hud_progress_32px",
		w = self._downloads_panel:w(),
		h = self._downloads_panel:h(),
		color = Color.red
	})]],
			cause = DB:has(Idstring("texture"), Idstring("guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas"))
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
			issue = [[<unit path="core/units/run_sequence_dummy/run_sequence_dummy"/>
				<object path="core/units/run_sequence_dummy/run_sequence_dummy"/>
				<sequence_manager path="core/units/run_sequence_dummy/run_sequence_dummy"/>]],
			fix = [[<!-- <unit path="core/units/run_sequence_dummy/run_sequence_dummy"/> -->
				<!-- <object path="core/units/run_sequence_dummy/run_sequence_dummy"/> -->
				<!-- <sequence_manager path="core/units/run_sequence_dummy/run_sequence_dummy"/> -->]],
			cause = false --I need to find out which version it's fixed in.
		}
	}

	todo["Classes/Frameworks.lua"] = {
		{
			issue = 'self:FindAlreadyOverriden',
			fix = '-- self:FindAlreadyOverriden',
			cause = game_version(16.5)
		}
	}
	
	todo["Classes/Managers/FileManager.lua"] = {
		{
			issue = 'Application:reload_textures',
			fix = '-- Application:reload_textures',
			cause = game_version(54.7)
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
			cause = game_version(54.7)
		},
		{
			issue = 'if not DB.create_entry then',
			fix = 'if not (DB and DB.create_entry) then',
			cause = false --I need to find out which version it's fixed in.
		}
	}

	todo["Classes/WeaponSkinExtension.lua"] = {
		{
			issue = 'require',
			fix = '-- require',
			cause = game_version(54.7)
		}
	}

	todo["Hooks/Items/PlayerStyleGloveHooks.lua"] = {
		{
			issue = 'local F',
			fix = '-- local F',
			cause = game_version(95.894)
		}
	}

	todo["Hooks/Items/NetworkPeer.lua"] = {
		{
			issue = 'self:beardlib_reload_outfit',
			fix = '-- self:beardlib_reload_outfit',
			cause = game_version(93.844)
		}
	}

	todo["Hooks/Items/NetworkHooks.lua"] = {
		{
			issue = 'peer:beardlib_reload_outfit',
			fix = '-- peer:beardlib_reload_outfit',
			cause = game_version(93.844)
		}
	}
	
	todo["Modules/PD2/LevelModule.lua"] = {
		{
			issue = 'l_self.ai_groups[self._config.ai_group_type] or l_self.ai_groups.default',
			fix = '"america"',
			cause = game_version(50.0)
		}
	}

	todo["Modules/PD2/NarrativeModule.lua"] = {
		{
			issue = 'narr_self.stages[stage.level_id] = stage',
			fix = [[if narr_self.stages then
					narr_self.stages[stage.level_id] = stage
				end]],
			cause = game_version(65.0)
		},
		{
			issue = 'narr_self.stages[_stage.level_id] = _stage',
			fix = [[if narr_self.stages then
						narr_self.stages[_stage.level_id] = _stage
					end]],
			cause = game_version(65.0)
		}
	}

	todo["Hooks/Maps/NetworkHooks.lua"] = {
		{
			issue = 'managers.job:current_world_setting()',
			fix = 'nil',
			cause = game_version(12.1)
		}
	}

	todo["Hooks/Maps/Hooks.lua"] = {
		{
			issue = 'KillzoneManager.type_upd_funcs.kill = function (obj, t, dt, data)',
			fix = [[KillzoneManager.type_upd_funcs = {}
	KillzoneManager.type_upd_funcs.kill = function (obj, t, dt, data)]],
			cause = game_version(136.173)
		}
	}

	todo["Hooks/Items/Hooks.lua"] = {
		{
			issue = 'self.weapon_charms',
			fix = '-- self.weapon_charms',
			cause = game_version(110.41)
		}
	}

	todo["Hooks/Music/Hooks.lua"] = {
		{
			issue = 'local F',
			fix = '-- local F',
			cause = game_version(14.0)
		}
	}
	
	todo["Classes/Utils/FileIO.lua"] = {
		{
			issue = 'function FileIO:GetFiles(path)',
			fix = [[function FileIO:GetFiles(path)
	if not file.DirectoryExists(path) then
		return {}
	end
]],
			cause = false --I need to find out which version it's fixed in.
		},
		{
			issue = 'SystemFS:rename_file',
			fix = 'os.rename',
			cause = false --I need to find out which version it's fixed in.
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

-- if not file.FileExists then
	function file.FileExists(path)
		return os.rename(path, path)
	end
-- end

-- if not file.DirectoryExists then
	function file.DirectoryExists(path)
		return os.rename(path, path)
	end
-- end

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