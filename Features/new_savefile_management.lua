
SavefileManager.SAVE_SYSTEM = type(Steam) ~= "userdata" and "local_hdd" or "steam_cloud"
SavefileManager.PROGRESS_SLOT = 2013
SavefileManager.BACKUP_SLOT = 2013
SavefileManager._task_queue = {}
SavefileManager.max_slots = 10

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

local function message_dialog(title, text, func, ok_button_text)
	local button_ok = {text = ok_button_text or managers.localization:text("dialog_ok")}

	if func then
		button_ok.callback_func = func
	end

	managers.system_menu:show({
		title = title,
		text = text,
		button_list = {button_ok}
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

function SavefileManager:ported_data_fix()
	-- local save_slot = Global.save_slots.current_slot
	-- if not Global.save_slots[save_slot] then
	-- 	return
	-- end

	-- if Global.save_slots[save_slot].SkillTreeManager.VERSION ~= managers.skilltree.VERSION then
	-- 	Global.save_slots[save_slot]["SkillTreeManager" .. Global.save_slots[save_slot].SkillTreeManager.VERSION] = Global.save_slots[save_slot].SkillTreeManager
	-- 	if Global.save_slots[save_slot]["SkillTreeManager" .. managers.skilltree.VERSION] then
	-- 		Global.save_slots[save_slot].SkillTreeManager = Global.save_slots[save_slot]["SkillTreeManager" .. managers.skilltree.VERSION]
	-- 	else
	-- 		managers.skilltree:save(Global.save_slots[save_slot])
	-- 		managers.menu:show_skilltree_reseted()
	-- 		Global.save_slots[save_slot].PlayerManager.kit.equipment_slots = {}
	-- 	end
	-- end
	
	-- Global.save_slots[save_slot].stashed_items = Global.save_slots[save_slot].stashed_items or {}

	-- local default = managers.blackmarket:get_default_mask_blueprint()
	-- local blueprint_items = {
	-- 	color = "colors",
	-- 	color_a = "colors",
	-- 	color_b = "colors",
	-- 	color_c = "colors",
	-- 	material = "materials",
	-- 	pattern = "textures",
	-- }
	
	-- local returned_items = ""
	-- for id, item in pairs(Global.save_slots[save_slot].stashed_items) do
	-- 	local return_from_stash_allowed = true

	-- 	if item.mask_id then
	-- 		if tweak_data.blackmarket.masks[item.mask_id] then
	-- 			for type_id, blueprints_tweak in pairs(blueprint_items) do
	-- 				if not default[type_id] and item.blueprint[type_id] then
	-- 					return_from_stash_allowed = false
	-- 				end
					
	-- 				if (default[type_id] and not item.blueprint[type_id]) or (item.blueprint[type_id] and default[type_id] and not tweak_data.blackmarket[blueprints_tweak][item.blueprint[type_id].id]) then
	-- 					return_from_stash_allowed = false
	-- 				end
	-- 			end
	-- 		end
	-- 	else
	-- 		if not tweak_data.weapon[item.weapon_id] then
	-- 			return_from_stash_allowed = false
	-- 		else
	-- 			for _, part_id in pairs(item.blueprint) do
	-- 				if not tweak_data.weapon.factory.parts[part_id] then
	-- 					return_from_stash_allowed = false
	-- 					break
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	-- 	if return_from_stash_allowed then
	-- 		local item_name = (item.mask_id and tweak_data.blackmarket.masks[item.mask_id] and managers.localization:text(tweak_data.blackmarket.masks[item.mask_id].name_id)) or (item.weapon_id and tweak_data.weapon[item.weapon_id] and managers.localization:text(tweak_data.weapon[item.weapon_id].name_id))
	-- 		table.insert(Global.save_slots[save_slot].blackmarket.crafted_items[item.category], item.slot, item)
	-- 		returned_items = returned_items .. string.format("[Slot %s] %s (%s)", item.slot, item_name, item.category:capitalize()) .. "\n"
	-- 		Global.save_slots[save_slot].stashed_items[id] = nil
	-- 	end
	-- end
	
	-- if returned_items ~= "" then
	-- 	message_dialog(managers.localization:text("sblt_cus_returned_title"), managers.localization:text("sblt_cus_returned_text") .. "\n\n" .. returned_items)
	-- end

	-- local stashed_items = ""
	-- local function add_to_stash(category, id, item)
	-- 	if not self["stashed_equipped_" .. category] then
	-- 		self["stashed_equipped_" .. category] = item.equipped
	-- 	end
		
	-- 	item.category = category
	-- 	item.slot = id
	-- 	item.equipped = false
	-- 	table.insert(Global.save_slots[save_slot].stashed_items, item)
	-- 	Global.save_slots[save_slot].blackmarket.crafted_items[category][id] = nil
	-- 	stashed_items = stashed_items .. string.format("[Slot %s] %s (%s)", id, item.mask_id or item.weapon_id, category:capitalize()) .. "\n"
	-- end

	-- for category, data in pairs(Global.save_slots[save_slot].blackmarket.crafted_items) do
	-- 	for id, item in pairs(Global.save_slots[save_slot].blackmarket.crafted_items[category]) do
	-- 		if item.mask_id then
	-- 			if not tweak_data.blackmarket.masks[item.mask_id] then
	-- 				add_to_stash("masks", id, item)
	-- 			else
	-- 				if id == 1 then
	-- 					Global.save_slots[save_slot].blackmarket.crafted_items[category][id].blueprint = default
	-- 				else
	-- 					for type_id, blueprints_tweak in pairs(blueprint_items) do
	-- 						if not default[type_id] and item.blueprint[type_id] then
	-- 							add_to_stash("masks", id, item)
	-- 						elseif (default[type_id] and not item.blueprint[type_id]) or (item.blueprint[type_id] and default[type_id] and not tweak_data.blackmarket[blueprints_tweak][item.blueprint[type_id].id]) then
	-- 							add_to_stash("masks", id, item)
	-- 						end
	-- 					end
	-- 				end
	-- 			end
	-- 		else
	-- 			if not tweak_data.weapon[item.weapon_id] then
	-- 				add_to_stash(category, id, item)
	-- 			else
	-- 				for _, part_id in pairs(Global.save_slots[save_slot].blackmarket.crafted_items[category][id].blueprint) do
	-- 					if not tweak_data.weapon.factory.parts[part_id] then
	-- 						add_to_stash(category, id, item)
	-- 						break
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	-- 	if self["stashed_equipped_" .. category] then
	-- 		if category == "masks" then
	-- 			Global.save_slots[save_slot].blackmarket.crafted_items[category][1].equipped = true
	-- 		else
	-- 			local weapon_id = category == "primaries" and "amcar" or "glock_17"
	-- 			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	-- 			local blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
				
	-- 			table.insert(Global.save_slots[save_slot].blackmarket.crafted_items[category], 1, {
	-- 				weapon_id = weapon_id,
	-- 				factory_id = factory_id,
	-- 				blueprint = blueprint,
	-- 				equipped = true
	-- 			})
	-- 		end
	-- 	end
	-- end

	-- if stashed_items ~= "" then
	-- 	message_dialog(managers.localization:text("sblt_cus_stashed_title"), managers.localization:text("sblt_cus_stashed_text") .. "\n\n" .. stashed_items)
	-- end

	-- for _, deployable in pairs(Global.save_slots[save_slot].PlayerManager.kit.equipment_slots) do
	-- 	if not tweak_data.equipments[deployable] then
	-- 		table.delete(Global.save_slots[save_slot].PlayerManager.kit.equipment_slots, deployable)
	-- 	end
	-- end

	-- Global.save_slots[save_slot].blackmarket.new_item_type_unlocked = {}
	-- Global.save_slots[save_slot].inventory_version = SBLT_CUS:game_version()
end

function SavefileManager:perform_load(cache, progress_port)
	local matchmake_key = managers.network.matchmake._BUILD_SEARCH_INTEREST_KEY
	if not progress_port then
		Global.save_slots = cache or {}
		Global.save_slots.current_slot = Global.save_slots.current_slot or 1
	end

	if progress_port and cache then
		if not cache.UserManager then
			managers.user:save(cache)
			cache.UserManager[10] = false
			cache.UserManager[36] = 1.4
		end

		Global.save_slots[Global.save_slots.current_slot] = cache
		Global.save_slots[Global.save_slots.current_slot].game_version = matchmake_key
	end


	local data = Global.save_slots[Global.save_slots.current_slot]
	if not data then
		self:port_progress()
		
		return
	end

	local game_version = Global.save_slots[Global.save_slots.current_slot].game_version
	if game_version ~= matchmake_key then
		local version_matched = nil
		for slot, slot_data in pairs(Global.save_slots) do
			if type(slot_data) == "table" and slot_data.game_version and slot_data.game_version == matchmake_key then
				version_matched = slot
			end
		end

		if version_matched then
			message_dialog(managers.localization:text("sblt_cus_game_version_changed"), managers.localization:text("sblt_cus_slot_switched"))
			data = Global.save_slots[version_matched]
			Global.save_slots.current_slot = version_matched
		else
			message_dialog(managers.localization:text("sblt_cus_game_version_changed"), managers.localization:text("sblt_cus_slot_not_found"))
			self:change_slot()
			return
		end
	end

	if type(data) == "table" and table.size(data) > 0 then
		if progress_port then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
			managers.menu:do_clear_progress()
		end

		-- if not data.inventory_version or (data.inventory_version and data.inventory_version ~= SBLT_CUS:game_version()) then
		-- 	self:ported_data_fix()
		-- end

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
					if class == "music" then
						managers[class]:load_profile(data.music_profile or {})
					else
						managers[class]:load_profile(data)
					end
				end
			end
		end

		if managers.menu_scene then
			managers.menu_scene:on_blackmarket_reset()
		end

		if managers.menu_component then
			managers.menu_component:refresh_player_profile_gui()
		end

		self:refresh_current_slot_name()

		managers.blackmarket:verify_dlc_items()
	end

	if progress_port then
		self:_save()
	end

	Global.savefile_manager.progress_loaded = true

	if data.job_preserved then
		self.show_continue_job_button = data
		self:preserved_job_dialog(data)
	end
end

function SavefileManager:preserved_job_dialog(data)
	local button_list = {}
	table.insert(button_list, {text = managers.localization:text("dialog_yes"), callback_func = function()
			self.job_preserved = true

			Global.job_manager = data.job_preserved.job_manager
			Global.game_settings = data.job_preserved.game_settings
			Global.loot_manager = data.job_preserved.loot_manager
			Global.asset_manager = data.job_preserved.asset_manager
			Global.mission_manager = data.job_preserved.mission_manager

			if Global.game_settings.single_player then
				MenuCallbackHandler:play_single_player()
				MenuCallbackHandler:start_single_player_job({
					difficulty = Global.game_settings.difficulty,
					job_id = Global.job_manager.current_job.job_id
				})
			else
				if managers.job:activate_job(Global.job_manager.current_job.job_id) then
					managers.network.matchmake:create_lobby(MenuCallbackHandler:get_matchmake_attributes())
				end
			end
		end
	})
	table.insert(button_list, {text = managers.localization:text("dialog_no"), cancel_button = self.preserved_job_canceled, callback_func = function() self.preserved_job_canceled = true end})

	local job = data.job_preserved.job_manager.current_job
	local contract_info = {}
	table.insert(contract_info, string.format("%s %s", managers.localization:text(tweak_data.narrative.jobs[job.job_id].name_id), tweak_data.narrative.jobs[job.job_id].professional and "[" .. managers.localization:to_upper_text("cn_menu_pro_job") .. "]" or ""))

	if job.stages and job.stages > 1 then
		table.insert(contract_info, managers.localization:text("hud_days_title", {DAY = job.current_stage, DAYS = job.stages}))
	end
	
	table.insert(contract_info, string.rep("", tweak_data:difficulty_to_index(data.job_preserved.game_settings.difficulty) - 2))
	
	managers.system_menu:show({
		title = managers.localization:text("sblt_cus_preserved_contract"),
		text = managers.localization:text("sblt_cus_preserved_contract_text") .. "\n\n" .. table.concat(contract_info, "\n"),
		button_list = button_list
	})
end

function SavefileManager:_load(selected_slot)
	if type(SaveGameManager) == "userdata" then
		local task_data = {
			queued_in_save_manager = true,
			task_type = 2,
			first_slot = selected_slot or self.PROGRESS_SLOT,
			save_system = self.SAVE_SYSTEM
		}

		SaveGameManager:load(task_data, function(_, result_data)
			local slot_data = type_name(result_data) == "table" and result_data[selected_slot or self.PROGRESS_SLOT]
			if slot_data then
				if slot_data.status ~= "OK" then
					message_dialog(managers.localization:text("sblt_cus_new_save_system"), string.format(slot_data.status == "FILE_NOT_FOUND" and managers.localization:text("sblt_cus_savefile_not_found") or managers.localization:text("sblt_cus_save_not_loaded"), slot_data.status), function()
						if slot_data.status == "FILE_NOT_FOUND" then
							self:perform_load(slot_data.data, selected_slot)
						else
							self:_load(selected_slot)
						end
					end, slot_data.status ~= "FILE_NOT_FOUND" and managers.localization:text("sblt_cus_try_again"))
				else
					self:perform_load(slot_data.data, selected_slot)
				end
			end
		end)
	elseif type(NewSave) == "userdata" then
		local task = NewSave:load({
			save_slots = selected_slot or self.PROGRESS_SLOT,
			save_system = self.SAVE_SYSTEM
		})

		table.insert(self._task_queue, SavefileTaskHandler:new(task, 2, function(save_data)
			local status = table.get_key(SaveData, save_data:status())
			if status ~= "OK" then
				message_dialog(managers.localization:text("sblt_cus_new_save_system"), string.format(status == "FILE_NOT_FOUND" and managers.localization:text("sblt_cus_savefile_not_found") or managers.localization:text("sblt_cus_save_not_loaded"), status), function()
					if status == "FILE_NOT_FOUND" then
						self:perform_load(save_data:information(), selected_slot)
					else
						self:_load(selected_slot)
					end
				end, status ~= "FILE_NOT_FOUND" and managers.localization:text("sblt_cus_try_again"))
			else
				self:perform_load(save_data:information(), selected_slot)
			end
		end, function() end))
	end
end

function SavefileManager:perform_save(save_tbl)
	save_tbl.save_time = os.date()
	local old_data = deep_clone(save_tbl)
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
				if class == "music" then
					save_tbl.music_profile = save_tbl.music_profile or {}
					managers[class]:save_profile(save_tbl.music_profile)
				else
					managers[class]:save_profile(save_tbl)
				end
			end
		end
	end

	if not managers.infamy and old_data.ExperienceManager then
		save_tbl.ExperienceManager.rank = old_data.ExperienceManager.rank
	end
end

function SavefileManager:_save(_, _, save_system)
	self:perform_save(Global.save_slots[Global.save_slots.current_slot] or {})

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

	self:refresh_current_slot_name(true)
	self:show_icon(utf8.to_upper(managers.localization:text("savefile_saving")))
end

function SavefileManager:port_confirm_dialog(result_data, slot)
	local dialog_data = {
		button_list = {}
	}
	if slot then
		dialog_data.title = managers.localization:text("sblt_cus_confirm_changes")
		dialog_data.text = string.format(managers.localization:text("sblt_cus_port_from_savefile"), savefile_name(slot))
	else
		dialog_data.title = managers.localization:text("dialog_warning_title")
		dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_to_clear_progress")
	end

	table.insert(dialog_data.button_list, {
		text = managers.localization:text("dialog_yes"),
		callback_func = function()
			if self._empty_slot then
				Global.save_slots.current_slot = self._empty_slot
				self._empty_slot = nil
				self:show_icon(utf8.to_upper(managers.localization:text("sblt_cus_slot_changed")))
			end
			
			if slot then
				self:_load(slot)
			else
				local new_data = {}
				self:perform_save(new_data)
				if new_data.UserManager then
					new_data.UserManager[10] = false
					new_data.UserManager[36] = 1.4
				end
				self:perform_load(new_data, "port_progress")
			end
		end
	})

	table.insert(dialog_data.button_list, {
		text = managers.localization:text("dialog_no"),
		cancel_button = true,
		callback_func = function()
			self:port_progress_dialog(result_data)
		end
	})

	managers.system_menu:show(dialog_data)
end

function SavefileManager:port_progress_dialog(result_data)
	local dialog_data = {
		title = managers.localization:text("sblt_cus_port_progress"),
		text = managers.localization:text("sblt_cus_port_dialog"),
		button_list = {}
	}

	for slot, _ in pairs(result_data) do
		local slot_name_text = slot_names[slot] and string.format("(%s)  ", slot_names[slot]) or ""
		table.insert(dialog_data.button_list, {
			text = string.format("%s%s", slot_name_text, tostring(slot)),
			num = slot,
			callback_func = function()
				self:port_confirm_dialog(result_data, slot)
			end,
		})
	end
	table.sort(dialog_data.button_list, function(a, b)
		return a.num > b.num
	end)

	if not Global.savefile_manager.progress_loaded then
		table.insert(dialog_data.button_list, {callback_func = function()
			self:port_progress_dialog(result_data)
		end})

		table.insert(dialog_data.button_list, {
			text = managers.localization:text("menu_clear_progress"),
			callback_func = function()
				self:port_confirm_dialog(result_data)
			end,
		})
	end

	if Global.savefile_manager.progress_loaded or self._empty_slot then
		table.insert(dialog_data.button_list, {callback_func = function()
			self:port_progress_dialog(result_data)
		end})

		local cancel_button = {
			text = managers.localization:text("menu_back"),
			cancel_button = true
		}

		if self._empty_slot then
			cancel_button.callback_func = function()
				self:change_slot()
				self._empty_slot = nil
			end
		end

		table.insert(dialog_data.button_list, cancel_button)
	end

	managers.system_menu:show_buttons(dialog_data)
end

function SavefileManager:port_progress()
	if type(SaveGameManager) == "userdata" then
		SaveGameManager:iterate_savegame_slots({
			queued_in_save_manager = true,
			task_type = 6,
			save_system = self.SAVE_SYSTEM,
			first_slot = self.MIN_SLOT,
			last_slot = self.MAX_SLOT
		}, function(_, result_data)
			self:port_progress_dialog(result_data)
		end)
	elseif type(NewSave) == "userdata" then
		local result_data = {}
		table.insert(self._task_queue, SavefileTaskHandler:new(NewSave:all_slots({save_system = self.SAVE_SYSTEM}), 1, function(slot)
			result_data[slot] = true
		end, function() self:port_progress_dialog(result_data) end))
	end
end

function SavefileManager:perform_slot_change(slot)
	if Global.save_slots.current_slot ~= slot or not Global.savefile_manager.progress_loaded then
		if Global.save_slots[slot] then
			Global.save_slots.current_slot = slot
			self:perform_load(Global.save_slots[slot], true)
			if Global.save_slots[slot] and Global.savefile_manager.progress_loaded then
				self:show_icon("SLOT CHANGED")
			end
		elseif not Global.save_slots[slot] then
			self._empty_slot = slot
			self:port_progress()
		end
	end
end

function SavefileManager:change_slot()
	local dialog_data = {
		title = managers.localization:text("sblt_cus_choose_slot"),
		button_list = {}
	}

	for i = 1, self.max_slots do
		table.insert(dialog_data.button_list, {
			text = self:current_slot(Global.save_slots[i], i),
			callback_func = function()
				local matchmake_key = managers.network.matchmake._BUILD_SEARCH_INTEREST_KEY
				local game_version = Global.save_slots[i] and Global.save_slots[i].game_version
				if game_version and game_version ~= matchmake_key then
					local dialog_data = {
						title = managers.localization:text("sblt_cus_choose_slot"),
						text = string.format(managers.localization:text("sblt_cus_dialog_different_version"), matchmake_key, game_version),
						button_list = {}
					}

					local yes_button = {
						text = managers.localization:text("dialog_yes"),
						callback_func = function()
							self:perform_slot_change(i)
						end
					}
					table.insert(dialog_data.button_list, yes_button)

					local cancel_button = {
						text = managers.localization:text("menu_back"),
						callback_func = function()
							self:change_slot()
						end,
						cancel_button = true
					}
					table.insert(dialog_data.button_list, cancel_button)

					managers.system_menu:show(dialog_data)
				else
					self:perform_slot_change(i)
				end
			end
		})
	end

	if Global.savefile_manager.progress_loaded then
		table.insert(dialog_data.button_list, {})

		local cancel_button = {
			text = managers.localization:text("menu_back"),
			cancel_button = true
		}
		table.insert(dialog_data.button_list, cancel_button)
	end

	managers.system_menu:show(dialog_data)
end

function SavefileManager:show_icon(text)
	self._workspace:show()
	self._hide_gui_time = nil
	self._show_gui_time = TimerManager:main():time()
	self._gui_script:set_text(text)
	self._gui_script.indicator:animate(self._gui_script.saving)
end

function SavefileManager:current_slot(save_data, slot)
	local text = "Empty"
	if save_data then
		text = save_data.save_time or "--/--/--"

		if save_data.game_version then
			text = "(" .. save_data.game_version .. ")     " .. text
		end
	end

	return string.format("%s     [Slot %s]", text, string.rep("0", math.max(2 - string.len(slot), 0)) .. slot)
end

function SavefileManager:refresh_current_slot_name(current_node)
	local logic = managers.menu:active_menu() and managers.menu:active_menu().logic
	if logic then
		local node = logic:get_node("options")
		if node and node:parameters().name == "options" then
			local item = node:item("current_slot")
			if item then
				local slot = Global.save_slots.current_slot
				item:set_parameter("text_id", self:current_slot(Global.save_slots[slot], slot))
				managers.menu:active_menu().logic:refresh_node()
			end
		end
	end
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
	return not Global.savefile_manager.progress_loaded
end

function SavefileManager:load_progress()
end

function SavefileManager:load_game()
end

function SavefileManager:load_settings()
end