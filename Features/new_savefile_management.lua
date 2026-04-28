
SavefileManager.SAVE_SYSTEM = type(Steam) ~= "userdata" and "local_hdd" or "steam_cloud"
SavefileManager.PROGRESS_SLOT = 2013
SavefileManager.BACKUP_SLOT = 2013
SavefileManager._task_queue = {}

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

function SavefileManager:get_progress_from_older_version_slot(save_slot)
    if not tonumber(save_slot) then
        return
    end

    local donor_slot, donor_data = nil, nil
    for slot_version, data in pairs(Global.save_slots) do
        local slot_ver_num = tonumber(slot_version)
        if slot_ver_num and tonumber(save_slot) > tonumber(slot_ver_num) and tonumber(slot_ver_num) > tonumber(donor_slot or 0) then
            donor_slot, donor_data = slot_version, data
        end
    end

    return donor_slot, donor_data
end

function SavefileManager:perform_load(cache, progress_port)
	if cache then
		if progress_port then
			managers.menu:do_clear_progress()
			if not cache.UserManager then
				managers.user:save(cache)
			end
			local save_slot = Global.save_slots.current_slot
			Global.save_slots[save_slot] = Global.save_slots[save_slot] or {}
			self:perform_save(Global.save_slots[save_slot])

			for tbl, data in pairs(cache) do
				Global.save_slots[save_slot][tbl] = data
			end
		else
			cache.current_slot = current_slot or 1
			Global.save_slots = cache
		end
	end
	
	local save_slot = Global.save_slots.current_slot
	local data = Global.save_slots[save_slot]
	if not data then
		-- message_dialog("New Save Management System", "Data is not found.\n\nSuperBLT-CUS using it's own save management, your progresses from all versions will be separately stored into the single save file. If you have played u24.2, u37.1, and u76, system will port the progress automatically. Otherwise, you have to choose the save file from the list.")

		self:iterate_savefiles(function(result_data)
			self:port_progress_dialog(result_data, true)
		end)
		
		return
	end

	local game_version = Global.save_slots[save_slot].game_version
	if progress_port or not game_version or (game_version and game_version ~= SBLT_CUS:game_version()) then
		Global.save_slots[save_slot].game_version = SBLT_CUS:game_version()

		if Global.save_slots[save_slot].SkillTreeManager.VERSION > managers.skilltree.VERSION then
			managers.skilltree:save(Global.save_slots[save_slot])
			managers.menu:show_skilltree_reseted()
		end
		
		Global.save_slots[save_slot].stashed_items = Global.save_slots[save_slot].stashed_items or {}

		local default = managers.blackmarket:get_default_mask_blueprint()
		local blueprint_items = {
			color = "colors",
			color_a = "colors",
			color_b = "colors",
			color_c = "colors",
			material = "materials",
			pattern = "textures",
		}

		for id, item in pairs(Global.save_slots[save_slot].stashed_items) do
			local return_from_stash_allowed = true

			if item.mask_id then
				if tweak_data.blackmarket.masks[item.mask_id] then
					for type_id, blueprints_tweak in pairs(blueprint_items) do
						if not default[type_id] and item.blueprint[type_id] then
							return_from_stash_allowed = false
						end
						
						if (default[type_id] and not item.blueprint[type_id]) or (item.blueprint[type_id] and default[type_id] and not tweak_data.blackmarket[blueprints_tweak][item.blueprint[type_id].id]) then
							return_from_stash_allowed = false
						end
					end
				end
			else
				if not tweak_data.weapon[item.weapon_id] then
					return_from_stash_allowed = false
				else
					for part_index, part_id in pairs(item.blueprint) do
						if not tweak_data.weapon.factory.parts[part_id] then
							return_from_stash_allowed = false
							break
						end
					end
				end
			end

			if return_from_stash_allowed then
				table.insert(Global.save_slots[save_slot].blackmarket.crafted_items[item.category], item.slot, item)
				HudChallengeNotification.queue(string.format("%s %s [Slot %s]", item.category:upper(), item.mask_id or item.weapon_id, item.slot), string.format("Item is returned to the inventory."))
				Global.save_slots[save_slot].stashed_items[id] = nil
			end
		end

		local function add_to_stash(category, id, item)
			if not self["stashed_equipped_" .. category] then
				self["stashed_equipped_" .. category] = item.equipped
			end
			
			item.category = category
			item.slot = id
			item.equipped = false
			table.insert(Global.save_slots[save_slot].stashed_items, item)
			Global.save_slots[save_slot].blackmarket.crafted_items[category][id] = nil
			HudChallengeNotification.queue(string.format("%s [Slot %s] %s ", item.mask_id or item.weapon_id, id, category:upper()), string.format("This item is stashed, because it does not compatible on this version or have modded with uncompatible items. It will be returned back as soon as you will lauch the version where it's compatible."))
		end

		for category, data in pairs(Global.save_slots[save_slot].blackmarket.crafted_items) do
			for id, item in pairs(Global.save_slots[save_slot].blackmarket.crafted_items[category]) do
				if item.mask_id then
					if not tweak_data.blackmarket.masks[item.mask_id] then
						add_to_stash("masks", id, item)
					else
						for type_id, blueprints_tweak in pairs(blueprint_items) do
							if not default[type_id] and item.blueprint[type_id] then
								add_to_stash("masks", id, item)
							elseif (default[type_id] and not item.blueprint[type_id]) or (item.blueprint[type_id] and default[type_id] and not tweak_data.blackmarket[blueprints_tweak][item.blueprint[type_id].id]) then
								add_to_stash("masks", id, item)
							end
						end
					end
				else
					if not tweak_data.weapon[item.weapon_id] then
						add_to_stash(category, id, item)
					else
						for part_index, part_id in pairs(Global.save_slots[save_slot].blackmarket.crafted_items[category][id].blueprint) do
							if not tweak_data.weapon.factory.parts[part_id] then
								add_to_stash(category, id, item)
								break
							end
						end
					end
				end
			end

			if self["stashed_equipped_" .. category] then
				if category == "masks" then
					Global.save_slots[save_slot].blackmarket.crafted_items[category][1].equipped = true
				else
					local weapon_id = category == "primaries" and "amcar" or "glock_17"
					local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
					local blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
					
					table.insert(Global.save_slots[save_slot].blackmarket.crafted_items[category], 1, {
						weapon_id = weapon_id,
						factory_id = factory_id,
						blueprint = blueprint,
						equipped = true
					})
				end
			end
		end

		Global.save_slots[save_slot].PlayerManager.kit.equipment_slots = {}
		Global.save_slots[save_slot].blackmarket.new_item_type_unlocked = {}
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

function SavefileManager:perform_save(save_tbl)
	for _, class in pairs(managers_list) do
		if managers[class] then
			if type(managers[class].save) == "function" then
				managers[class]:save(save_tbl)
			end

			if type(managers[class].save_savedata) == "function" then
				managers[class]:save_savedata(save_tbl)
			end

			if type(managers[class].save_settings) == "function" then
				managers[class]:save_settings(save_tbl)
			end

			if type(managers[class].save_job_values) == "function" then
				managers[class]:save_job_values(save_tbl)
			end

			if type(managers[class].save_profile) == "function" then
				managers[class]:save_profile(save_tbl)
			end
		end
	end
end

function SavefileManager:_save(slot, ignore_current_progress, save_system)
	if not ignore_current_progress then
		self:perform_save(Global.save_slots[Global.save_slots.current_slot] or {})
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