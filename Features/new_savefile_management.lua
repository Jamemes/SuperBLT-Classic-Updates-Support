
SavefileManager.SAVE_SYSTEM = type(Steam) ~= "userdata" and "local_hdd" or "steam_cloud"
SavefileManager.PROGRESS_SLOT = 2013
SavefileManager.BACKUP_SLOT = 2013
SavefileManager._task_queue = {}

local game_ver = SBLT_CUS:game_version("ver")
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

local function savefile_name(slot)
	return string.format("save%s.sav", string.rep("0", 3 - string.len(slot)) .. slot)
end

local function update_name(slot)
	local first = string.sub(tostring(slot), 0, 1)
	local ver, _ = string.gsub(tostring(slot), ".", first .. "%.", 1)
	local ver_str = tweak_data.updates_table[ver] or tostring(slot)
	ver_str = ver_str ~= "Release" and "Update " .. ver_str or ver_str
	return ver_str
end

local function message_dialog(title, text)
	managers.system_menu:show({
		title = title,
		text = text,
		button_list = {{text = managers.localization:text("dialog_ok")}}
	})
end

local slot_names = {
	[0] = "Vanilla Settings",
	[98] = "Vanilla",
	[97] = "Tournament",
	[11] = "Update 24.2",
	[37] = "Update 37.1",
	[76] = "Update 76",
	[77] = "Restoration Mod",
	[24] = "Original Pack",
	[26] = "Classic Heisting",
	[21] = "Eclipse",
	[96] = "VR Beta",
	[12] = "VR Settings",
}

function SavefileManager:storage_changed()
	self:_load()
end

function SavefileManager:get_progress_from_older_version_slot(game_ver)
    if not tonumber(game_ver) then
        return
    end

    local donor_slot, donor_data = nil, nil
    for slot_version, data in pairs(Global.save_slots) do
        local slot_ver_num = tonumber(slot_version)
        if slot_ver_num and tonumber(game_ver) > tonumber(slot_ver_num) and tonumber(slot_ver_num) > tonumber(donor_slot or 0) then
            donor_slot, donor_data = slot_version, data
        end
    end

    return donor_slot, donor_data
end

function SavefileManager:perform_load(cache, progress_port)
	if progress_port then
		if not cache.UserManager and cache.SkillTreeManager then
			managers.menu:do_clear_progress()
			managers.user:save(cache)
			Global.save_slots[game_ver] = deep_clone(cache)
			
			if cache.SkillTreeManager.VERSION > managers.skilltree.VERSION then
				managers.skilltree:save(Global.save_slots[game_ver])
				managers.menu:show_skilltree_reseted()
			end

			for id, mask in pairs(Global.save_slots[game_ver].blackmarket.crafted_items.masks) do
				if not tweak_data.blackmarket.masks[mask.mask_id] then
					if mask.equipped then
						Global.save_slots[game_ver].blackmarket.crafted_items.masks[1].equipped = true
					end

					Global.save_slots[game_ver].blackmarket.crafted_items.masks[id] = nil
				else	
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
							Global.save_slots[game_ver].blackmarket.crafted_items.masks[id].blueprint[type_id] = nil
						elseif (default[type_id] and not mask.blueprint[type_id]) or (mask.blueprint[type_id] and default[type_id] and not tweak_data.blackmarket[blueprints_tweak][mask.blueprint[type_id].id]) then
							Global.save_slots[game_ver].blackmarket.crafted_items.masks[id].blueprint[type_id] = default[type_id]
						end
					end

					if mask.modded and mask.blueprint.pattern.id == "no_color_no_material" then
						Global.save_slots[game_ver].blackmarket.crafted_items.masks[id].blueprint.pattern.id = "no_color_full_material"
					end
				end
			end

			for id, secondary in pairs(Global.save_slots[game_ver].blackmarket.crafted_items.secondaries) do
				if not tweak_data.weapon[secondary.weapon_id] then
					Global.save_slots[game_ver].blackmarket.crafted_items.secondaries[id] = nil
				else
					if secondary.equipped then
						Global.save_slots[game_ver].blackmarket.crafted_items.secondaries[id].equipped = false
					end

					for part_index, part_id in pairs(Global.save_slots[game_ver].blackmarket.crafted_items.secondaries[id].blueprint) do
						if not tweak_data.weapon.factory.parts[part_id] then
							Global.save_slots[game_ver].blackmarket.crafted_items.secondaries[id].blueprint[part_index] = nil
							Global.save_slots[game_ver].blackmarket.crafted_items.secondaries[id].global_values[part_id] = nil
						end
					end
				end
			end

			for id, primary in pairs(Global.save_slots[game_ver].blackmarket.crafted_items.primaries) do
				if not tweak_data.weapon[primary.weapon_id] then
					Global.save_slots[game_ver].blackmarket.crafted_items.primaries[id] = nil
				else
					if primary.equipped then
						Global.save_slots[game_ver].blackmarket.crafted_items.primaries[id].equipped = false
					end

					for part_index, part_id in pairs(Global.save_slots[game_ver].blackmarket.crafted_items.primaries[id].blueprint) do
						if not tweak_data.weapon.factory.parts[part_id] then
							Global.save_slots[game_ver].blackmarket.crafted_items.primaries[id].blueprint[part_index] = nil
							Global.save_slots[game_ver].blackmarket.crafted_items.primaries[id].global_values[part_id] = nil
						end
					end
				end
			end
		
			local secondary_factory_id = "wpn_fps_pis_g17"
			table.insert(Global.save_slots[game_ver].blackmarket.crafted_items.secondaries, 1, {
				equipped = true,
				factory_id = secondary_factory_id,
				blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(secondary_factory_id)),
				weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(secondary_factory_id),
				global_values = {}
			})

			local primary_factory_id = "wpn_fps_ass_amcar"
			table.insert(Global.save_slots[game_ver].blackmarket.crafted_items.primaries, 1, {
				equipped = true,
				factory_id = primary_factory_id,
				blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(primary_factory_id)),
				weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(primary_factory_id),
				global_values = {}
			})

			Global.save_slots[game_ver].PlayerManager.kit.equipment_slots = {}
			Global.save_slots[game_ver].blackmarket.new_item_type_unlocked = {}
		else
			message_dialog("Error", "This file cannot be used. Could be a setting slot.")
			return
		end
	else
		if cache then
			Global.save_slots = cache
		end
	end

	local data = Global.save_slots[game_ver]
	if not data then
		local donor_slot, donor_data = self:get_progress_from_older_version_slot(game_ver)
		message_dialog("New Save Management System", "Data is not found.\n\nSuperBLT-CUS using it's own save management, your progresses from all versions will be separately stored into the single save file. If you have played u24.2, u37.1, and u76, system will port the progress automatically. Otherwise, you have to choose the save file from the list.")

		self:iterate_savefiles(function(result_data)
			local slots_for_version = {
				["1.6.2"] = 11,
				["1.15.1"] = 37,
				["1.37.1"] = 76,
			}

			local savefile_donor = slots_for_version[SBLT_CUS:game_version()]
			if savefile_donor and result_data[savefile_donor] then
				message_dialog(slot_names[savefile_donor], string.format("Progress is fetched from the file %s.", savefile_name(savefile_donor)))
				self:_load(slots_for_version[SBLT_CUS:game_version()])
			elseif donor_slot and donor_data then
				message_dialog("Progress is copied", string.format("Progress is got fetched from %s.", update_name(donor_slot)))
				Global.save_slots[game_ver] = donor_data
				self:perform_load(cache, progress_port)
			else
				self:port_progress_dialog(result_data, true)
			end
		end)
		
		return
	end

	if type(data) == "table" and table.size(data) > 0 then
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

		if managers.menu_scene then
			managers.menu_scene:on_blackmarket_reset()
		end

		if progress_port then
			managers.menu:back(true)
		end
	end

	self._progress_loaded = true
end

function SavefileManager:_load(selected_slot)
	if type(SaveGameManager) == "userdata" then
		SaveGameManager:load({
			queued_in_save_manager = true,
			task_type = 2,
			first_slot = selected_slot or self.PROGRESS_SLOT,
			save_system = self.SAVE_SYSTEM
		}, function(_, result_data)
			if type_name(result_data) == "table" then
				for slot, slot_data in pairs(result_data) do
					if slot == (slot or self.PROGRESS_SLOT) and slot_data.status == "OK" then
						self:perform_load(slot_data.data, selected_slot)

						break
					else
						self:perform_load({}, selected_slot)
					end
				end
			end
		end)
	elseif type(NewSave) == "userdata" then
		local task = NewSave:load({
			save_slots = selected_slot or self.PROGRESS_SLOT,
			save_system = self.SAVE_SYSTEM
		})

		table.insert(self._task_queue, SavefileTaskHandler:new(task, 2, function(save_data)
			if save_data:status() == SaveData.OK then
				self:perform_load(save_data:information(), selected_slot)
			else
				self:perform_load({}, selected_slot)
			end
		end, function() end))
	end
end

function SavefileManager:_save(slot, ignore_current_progress, save_system)
	if not ignore_current_progress then
		local save_slot = Global.save_slots[game_ver] or {}
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
			first_slot = self.PROGRESS_SLOT,
			task_type = 3,
			subtitle = "",
			details = "",
			save_system = save_system or self.SAVE_SYSTEM,
			data = {Global.save_slots}
		}, function() end)
	elseif type(NewSave) == "userdata" then
		local param_map = {
			save_slots = self.PROGRESS_SLOT,
			save_system = save_system or self.SAVE_SYSTEM
		}
		local save_data = NewSave:create_save_data()
		save_data:set_subtitle("")
		save_data:set_details("")
		save_data:set_information(Global.save_slots)
		SavefileTaskHandler:new(NewSave:save(save_data, param_map), 3, function() end, nil, "progress")
	end

	self:show_icon(utf8.to_upper(managers.localization:text("savefile_saving")))
end

function SavefileManager:iterate_savefiles(func)
	if type(SaveGameManager) == "userdata" then
		SaveGameManager:iterate_savegame_slots({
			queued_in_save_manager = true,
			task_type = 6,
			save_system = self.SAVE_SYSTEM,
			first_slot = self.MIN_SLOT,
			last_slot = self.MAX_SLOT
		}, function(task_data, result_data)
			func(result_data)
		end)
	elseif type(NewSave) == "userdata" then
		local result_data = {}
		table.insert(self._task_queue, SavefileTaskHandler:new(NewSave:all_slots({save_system = self.SAVE_SYSTEM}), 1, function(slot)
			result_data[slot] = true
		end, function() func(result_data) end))
	end
end

function SavefileManager:port_confirm_dialog(result_data, no_data_found, slot)
	local dialog_data = {
		button_list = {}
	}
	if slot then
		dialog_data.title = "Confirm the changes"
		dialog_data.text = string.format("Are you sure you want port the progress from the file %s?\n\nYour current progress will be gone.", savefile_name(slot))
	else
		dialog_data.title = managers.localization:text("dialog_warning_title")
		dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_to_clear_progress")
	end

	table.insert(dialog_data.button_list, {
		text = managers.localization:text("dialog_yes"),
		callback_func = function()
			if slot then
				managers.savefile:_load(slot)
			else
				self._progress_loaded = true
			end
		end
	})

	local cancel_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true
	}
	
	if no_data_found then
		cancel_button.callback_func = function()
			self:port_progress_dialog(result_data, no_data_found)
		end
	end

	table.insert(dialog_data.button_list, cancel_button)

	managers.system_menu:show(dialog_data)
end

function SavefileManager:port_progress_dialog(result_data, no_data_found)
	local dialog_data = {
		title = "Port the Progress",
		text = "Choose the file to port the progress.\nsaveXXX.sav",
		button_list = {}
	}

	for slot, _ in pairs(result_data) do
		local slot_name_text = slot_names[slot] and string.format("(%s)  ", slot_names[slot]) or ""
		table.insert(dialog_data.button_list, {
			text = string.format("%s%s", slot_name_text, tostring(slot)),
			num = slot,
			callback_func = function()
				self:port_confirm_dialog(result_data, no_data_found, tonumber(slot))
			end,
		})
	end
	table.sort(dialog_data.button_list, function(a, b)
		return a.num > b.num
	end)

	table.insert(dialog_data.button_list, {})
	
	local cancel_button = {
		text = managers.localization:text("menu_back"),
		cancel_button = true
	}
	
	if no_data_found then
		cancel_button.text = managers.localization:text("menu_clear_progress")
		cancel_button.callback_func = function()
			self:port_confirm_dialog(result_data, no_data_found, slot)
		end
	end

	table.insert(dialog_data.button_list, cancel_button)

	managers.system_menu:show(dialog_data)
end

function SavefileManager:show_icon(text)
	self._workspace:show()
	self._hide_gui_time = nil
	self._show_gui_time = TimerManager:main():time()
	self._gui_script:set_text(text)
	self._gui_script.indicator:animate(self._gui_script.saving)
end

function SavefileManager:update(t, dt)
	while self._task_queue[1] do
		if not self._task_handler then
			self._task_handler = self._task_queue[1]
			table.remove(self._task_queue, 1)
		end
	end

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

function SavefileManager:is_in_loading_sequence()
	return not self._progress_loaded
end