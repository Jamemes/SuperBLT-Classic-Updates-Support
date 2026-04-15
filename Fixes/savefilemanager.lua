local ultimate_slot = 1
local game_version = SBLT_CUS:game_version("ver")
local managers_list = {
	"user",
	"music",
	"blackmarket",
	"upgrades",
	"experience",
	"player",
	"money",
	"challenges",
	"statistics",
	"event_jobs",
	"skilltree",
	"mission",
	"job",
	"dlc",
	"infamy",
	"features",
	"gage_assignment",
	"challenge",
	"multi_profile",
	"ban_list",
	"crimenet",
	"custom_safehouse",
	"butler_mirroring",
	"mutators",
	"tango",
	"crime_spree",
	"achievment",
	"story",
	"promo_unlocks",
	"generic_side_jobs",
	"skirmish",
	"socialhub",
}

if _G.IS_VR then
	table.insert(managers_list, 3, "vr")
end

-- local function make_fine_text(text)
-- 	local x, y, w, h = text:text_rect()

-- 	text:set_size(w, h)
-- 	text:set_position(math.round(text:x()), math.round(text:y()))

-- 	return x, y, w, h
-- end

NewSavefileManager = NewSavefileManager or class()
SavefileManager = NewSavefileManager or class()
function NewSavefileManager:init()
	Global.savefile_manager = Global.savefile_manager or {}
	Global.savefile_manager.save_slots = Global.savefile_manager.save_slots or {}
	Global.savefile_manager.backup_save_enabled = true

	self._workspace = managers.gui_data:create_saferect_workspace()
	self._gui = self._workspace:panel():gui(Idstring("guis/savefile_manager"))
	self._gui_script = self._gui:script()
	self._workspace:hide()

	self:load_progress()
end

function NewSavefileManager:save_progress(save_system, ignore_current_progress)
	if not ignore_current_progress then
		local save_slot = Global.savefile_manager.save_slots[game_version] or {}
		for _, class in pairs(managers_list) do
			if managers[class] then
				if type(managers[class].save) == "function" then
					managers[class]:save(save_slot)
				end

				if type(managers[class].save_savedata) == "function" then
					managers[class]:save_savedata(save_slot)
				end

				if type(managers[class].save_settings) == "function" then
					managers[class]:save_settings(save_slot)
				end

				if type(managers[class].save_job_values) == "function" then
					managers[class]:save_job_values(save_slot)
				end

				if type(managers[class].save_profile) == "function" then
					managers[class]:save_profile(save_slot)
				end
			end
		end
	end

	if type(SaveGameManager) == "userdata" then
		SaveGameManager:save({
			queued_in_save_manager = true,
			date_format = "%c",
			max_queue_size = 1,
			first_slot = ultimate_slot,
			task_type = 3,
			subtitle = "",
			details = "",
			save_system = save_system or "steam_cloud",
			data = {Global.savefile_manager.save_slots}
		}, function() end)
	elseif type(NewSave) == "userdata" then
		local param_map = {
			save_slots = ultimate_slot,
			save_system = save_system or "steam_cloud"
		}
		local save_data = NewSave:create_save_data()
		save_data:set_subtitle("")
		save_data:set_details("")
		save_data:set_information(Global.savefile_manager.save_slots)
		SavefileTaskHandler:new(NewSave:save(save_data, param_map), 3, function() end, nil, "progress")
	end

	self:show_icon(utf8.to_upper(managers.localization:text("savefile_saving")))
end

function NewSavefileManager:get_progress_from_older_version_slot(game_ver)
    if not tonumber(game_ver) then
        return
    end

    local donor_slot, donor_data = nil, nil
    for slot_version, data in pairs(Global.savefile_manager.save_slots) do
        local slot_ver_num = tonumber(slot_version)
        if slot_ver_num and tonumber(game_ver) > tonumber(slot_ver_num) and tonumber(slot_ver_num) > tonumber(donor_slot or 0) then
            donor_slot, donor_data = slot_version, data
        end
    end

    return donor_slot, donor_data
end

function NewSavefileManager:perform_load(cache)
	Global.savefile_manager.save_slots = cache

	if not cache[game_version] then
		local donor_slot, donor_data = self:get_progress_from_older_version_slot(game_version)
		local hint_dialog = {
			text = "New save file system containts all progress in a single save file, one for each game version. You have to port the progress from another save file manually, all you need to do is goto options and find 'Port the Progress' option, and enter the slot you played on, from 0 to 99.\n\n98 - Vanilla\n76 - Update 76\n37 - Update 37.1\n11 - Update 24.2\n69 - Default slot for all updates",
			button_list = {{
				text = managers.localization:text("dialog_ok")
			}}
		}

		if donor_slot and donor_data then
			local old_type = "0." .. tostring(donor_slot)
			local current_type = "1." .. tostring(donor_slot)
			local ver_str = tweak_data.updates_table[current_type] or tweak_data.updates_table[old_type] or tostring(donor_slot)
			ver_str = ver_str ~= "Release" and "Update " .. ver_str or ver_str
			managers.system_menu:show({
				text = "Progress is fetched from " .. ver_str,
				button_list = {{
					text = managers.localization:text("dialog_ok"),
					callback_func = function()
						managers.system_menu:show(hint_dialog)
					end
				}}
			})
		else
			managers.system_menu:show({
				text = "Progress is not found.",
				button_list = {{
					text = managers.localization:text("dialog_ok"),
					callback_func = function()
						managers.system_menu:show(hint_dialog)
					end
				}}
			})
		end

		Global.savefile_manager.save_slots[game_version] = donor_data or {}
	end

	local data = Global.savefile_manager.save_slots[game_version]
	if table.size(data) > 0 then
		for _, class in pairs(managers_list) do
			if managers[class] then
				if type(managers[class].load) == "function" and class ~= "music" then
					managers[class]:load(data)
				end

				if type(managers[class].load_savedata) == "function" then
					managers[class]:load_savedata(data)
				end

				if type(managers[class].load_settings) == "function" then
					managers[class]:load_settings(data)
				end

				if type(managers[class].load_job_values) == "function" then
					managers[class]:load_job_values(data)
				end

				if type(managers[class].load_profile) == "function" then
					managers[class]:load_profile(data)
				end
			end
		end
	end

	self._progress_loaded = true

	if managers.menu_scene then
		managers.menu_scene:on_blackmarket_reset()
	end
end

function NewSavefileManager:load_progress(save_system)
	if type(SaveGameManager) == "userdata" then
		SaveGameManager:load({
			queued_in_save_manager = true,
			task_type = 2,
			first_slot = ultimate_slot,
			save_system = save_system or "steam_cloud"
		}, function(_, result_data)
			if type_name(result_data) == "table" then
				for slot, slot_data in pairs(result_data) do
					if slot == 1 and slot_data.status == "OK" then
						self:perform_load(slot_data.data)

						break
					else
						self:perform_load({})
					end
				end
			end
		end)
	elseif type(NewSave) == "userdata" then
		local task = NewSave:load({
			save_slots = ultimate_slot,
			save_system = save_system or "steam_cloud"
		})

		self._task_handler = SavefileTaskHandler:new(task, 2, function(save_data)
			if save_data:status() == SaveData.OK then
				self:perform_load(save_data:information())
			else
				self:perform_load({})
			end
		end, function() end)
	end
end

function NewSavefileManager:show_icon(text)
	self._workspace:show()
	self._hide_gui_time = nil
	self._show_gui_time = TimerManager:main():time()
	self._gui_script:set_text(text)
	self._gui_script.indicator:animate(self._gui_script.saving)
end

function NewSavefileManager:update(t, dt)
	while self._task_handler do
		if self._task_handler:update() then
			self._task_handler:destroy()
			self._task_handler = nil
		end
	end

	if self._hide_gui_time and TimerManager:main():time() >= self._hide_gui_time then
		self._workspace:hide()
		self._gui_script:set_text("")
		self._hide_gui_time = nil
	end

	if self._show_gui_time then
		local main_time = TimerManager:main():time()
		local check_t = 3
		if check_t < main_time - self._show_gui_time then
			self._hide_gui_time = main_time
		elseif main_time - self._show_gui_time > 1 then
			self._hide_gui_time = self._show_gui_time + check_t
		else
			self._hide_gui_time = self._show_gui_time + check_t
		end
		self._show_gui_time = nil
	end
end

function NewSavefileManager:port_progress_from_another_savefile(required_slot, save_system)
	local function port_the_load(status_ok, status)
		if status_ok then
			if not status.UserManager then
				local default = {}
				managers.user:save(default)
				-- managers.skilltree:save(default)
				-- managers.blackmarket:save(default)
				local save_slot = Global.savefile_manager.save_slots[game_version]
				Global.savefile_manager.save_slots[game_version] = status
				Global.savefile_manager.save_slots[game_version].UserManager = default.UserManager

				for id, mask in pairs(Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.masks) do
					if not tweak_data.blackmarket.masks[mask.mask_id] then
						if mask.equipped then
							Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.masks[1].equipped = true
						end

						Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.masks[id] = nil
					else	
						if mask.modded then
							local default = managers.blackmarket:get_default_mask_blueprint()
							local blueprint_items = {
								color = "colors",
								color_a = "colors",
								color_b = "colors",
								color_c = "colors",
								material = "materials",
								pattern = "textures",
							}

							for type_id, blueprints_tweak in pairs(blueprint_items) do
								if not default[type_id] and mask.blueprint[type_id] then
									Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.masks[id].blueprint[type_id] = nil
								elseif (default[type_id] and not mask.blueprint[type_id]) or (mask.blueprint[type_id] and default[type_id] and not tweak_data.blackmarket[blueprints_tweak][mask.blueprint[type_id].id]) then
									Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.masks[id].blueprint[type_id] = default[type_id]
								end
							end

							if mask.blueprint.pattern.id == "no_color_no_material" then
								Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.masks[id].blueprint.pattern.id = "no_color_full_material"
							end
						end
					end
				end

				for id, secondary in pairs(Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.secondaries) do
					if not tweak_data.weapon[secondary.weapon_id] then
						if secondary.equipped then
							local secondary_factory_id = "wpn_fps_pis_g17"
							Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.secondaries[1] = {
								equipped = true,
								factory_id = secondary_factory_id,
								blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(secondary_factory_id)),
								weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(secondary_factory_id),
								global_values = {}
							}
						end

						Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.secondaries[id] = nil
					else
						Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.secondaries[id].global_values = {}
						Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.secondaries[id].blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(secondary.factory_id))
					end
				end
				
				for id, primary in pairs(Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.primaries) do
					if not tweak_data.weapon[primary.weapon_id] then
						if primary.equipped then
							local primary_factory_id = "wpn_fps_ass_amcar"
							Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.primaries[1] = {
								equipped = true,
								factory_id = primary_factory_id,
								blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(primary_factory_id)),
								weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(primary_factory_id),
								global_values = {}
							}
						end

						Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.primaries[id] = nil
					else
						Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.primaries[id].global_values = {}
						Global.savefile_manager.save_slots[game_version].blackmarket.crafted_items.primaries[id].blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(primary.factory_id))
					end
				end

				Global.savefile_manager.save_slots[game_version].PlayerManager.kit.equipment_slots = {}

				self:save_progress(nil, true)
				setup:quit()
			else
				managers.system_menu:show({
					title = "Error",
					text = "This slot cannot be used. May be a setting slot.",
					button_list = {{text = managers.localization:text("dialog_ok")}}
				})
			end
		else
			managers.system_menu:show({
				title = "Error",
				text = "Content from the save file can't be loaded.\n\nError message: " .. table.get_key(SaveData, save_data:status()),
				button_list = {{text = managers.localization:text("dialog_ok")}}
			})
		end
	end
	
	if type(SaveGameManager) == "userdata" then
		SaveGameManager:load({
			queued_in_save_manager = true,
			task_type = 2,
			first_slot = required_slot,
			save_system = save_system or "steam_cloud"
		}, function(_, result_data)
			if type_name(result_data) == "table" then
				for slot, slot_data in pairs(result_data) do
					port_the_load(slot == required_slot and slot_data.status == "OK", slot_data.data)
				end
			end
		end)
	elseif type(NewSave) == "userdata" then
		local task = NewSave:load({
			save_slots = slot,
			save_system = save_system or "steam_cloud"
		})

		self._task_handler = SavefileTaskHandler:new(task, 2, function(save_data)
			port_the_load(save_data:status() == SaveData.OK, save_data:information())
		end, function() end)
	end
end

function NewSavefileManager:is_in_loading_sequence()
	return not self._progress_loaded
end

function NewSavefileManager:is_active() end
function NewSavefileManager:savefile_access() end
function NewSavefileManager:add_load_sequence_done_callback_handler() end
function NewSavefileManager:setting_changed() end
function NewSavefileManager:add_load_done_callback() end
function NewSavefileManager:save_setting() end
function NewSavefileManager:add_active_changed_callback() end
function NewSavefileManager:break_loading_sequence() end
function NewSavefileManager:save_game() end
function NewSavefileManager:storage_changed() end
function NewSavefileManager:active_user_changed() end
function NewSavefileManager:check_space_required() end
function NewSavefileManager:fetch_savegame_hdd_space_required() end
function NewSavefileManager:load_settings() end
function NewSavefileManager:paused_update() end