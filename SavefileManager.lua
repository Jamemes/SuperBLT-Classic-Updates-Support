local reserved = {
	["1.6.2"] = 11,
	["1.15.1"] = 37,
}

SavefileManager.SETTING_SLOT = 2
SavefileManager._slots_per_version = {}
SavefileManager._forbidden_slots = {
	["98"] = "PAYDAY 2 Vanilla",
	["77"] = "Restoration mod",
	["24"] = "Original Pack",
	["26"] = "Classic Heisting",
	["21"] = "Eclipse",
}

function SavefileManager:save_progress_slots(tbl)
	local file, err = io.open("PROGRESS_SLOT.txt", "w")
	if not file then
		io.stderr:write(err .. "\n")
		return
	end

	for k, v in pairs(tbl) do
		file:write(k .. " " .. v .. "\n")
	end
	
	file:close()
end

			
local function load_progress_slot()
	local file, err = io.open("PROGRESS_SLOT.txt", "r")
	local function set_slots()
		local version_slot = reserved[tostring(Application:version())]
		if version_slot then
			SavefileManager.PROGRESS_SLOT = version_slot
			SavefileManager.BACKUP_SLOT = version_slot
		else
			SavefileManager.PROGRESS_SLOT = 69
			SavefileManager.BACKUP_SLOT = 69
		end
	end
	
	if not file then
		io.stderr:write(err .. "\n")
		set_slots()
		
		if not SavefileManager._slots_per_version[tostring(Application:version())] then		
			SavefileManager._slots_per_version[tostring(Application:version())] = SavefileManager.PROGRESS_SLOT
			SavefileManager:save_progress_slots(SavefileManager._slots_per_version)
		end
		
		return
	end
	
	local line = file:read()
	
	while line do
		if not string.match(line, "^#.+") then
			local key, val = string.match(line, "^(.+) (.+)$")
			if key and (val and val:gsub('%D', "") ~= "") then
				SavefileManager._slots_per_version[key] = val
			end
		end
		line = file:read()
	end
	
	for version, slot in pairs(SavefileManager._slots_per_version) do
		slot = tonumber(slot)
		if version == tostring(Application:version()) and string.len(tostring(slot)) == 2 then
			SavefileManager.PROGRESS_SLOT = slot
			SavefileManager.BACKUP_SLOT = slot
		end
	end
	
	if SavefileManager._forbidden_slots[tostring(SavefileManager.PROGRESS_SLOT)] then
		set_slots()
	end
	
	if not SavefileManager._slots_per_version[tostring(Application:version())] then		
		SavefileManager._slots_per_version[tostring(Application:version())] = SavefileManager.PROGRESS_SLOT
		SavefileManager:save_progress_slots(SavefileManager._slots_per_version)
	end
end

load_progress_slot()

-- pre-U27 save file fix
if SavefileManager._meta_data_slot_detected_done_callback then
	function SavefileManager:_meta_data_slot_detected_done_callback()
		self._loading_sequence = true
		print("SavefileManager:_meta_data_slot_detected_done_callback", self._has_meta_list)
		if not self._has_meta_list then
			print(" HAD NO SAVE GAMES")
			self._loading_save_games = {}
		else
			print(" #self._has_meta_list", #self._has_meta_list)
			self._loading_save_games = {}
			for _, slot in ipairs(self._has_meta_list) do
				if slot == self.SETTING_SLOT then
					self._loading_save_games[slot] = true
				elseif slot == self.PROGRESS_SLOT then
					-- self._loading_save_games[slot] = true
				end
			end
		end
		if (not self._has_meta_list or not table.contains(self._has_meta_list, self.PROGRESS_SLOT)) and self._backup_data then
			self._loading_save_games[self.PROGRESS_SLOT] = true
			self:_ask_load_backup("no_progress", true)
		end
	end
end

-- pre-U46 save file fix
if SavefileManager.clbk_result_iterate_savegame_slots then
	function SavefileManager:clbk_result_iterate_savegame_slots(task_data, result_data)
		print("[SavefileManager:clbk_result_iterate_savegame_slots]", inspect(task_data), inspect(result_data))
		if not self:_on_task_completed(task_data) then
			return
		end
		self._save_slots_to_load = {}
		local found_progress_slot
		if type_name(result_data) == "table" then
			for slot, slot_data in pairs(result_data) do
				print("slot:", slot, "\n", inspect(slot_data))
				if slot == self.SETTING_SLOT then
					self._save_slots_to_load[slot] = true
					self:load_settings()
				elseif slot == self.PROGRESS_SLOT then
					self._save_slots_to_load[slot] = true
					found_progress_slot = true
					self:load_progress()
				end
			end
		else
			Application:error("[SavefileManager:clbk_result_iterate_savegame_slots] error:", result_data)
		end
		if not found_progress_slot and self._backup_data then
			self._save_slots_to_load[self.PROGRESS_SLOT] = true
			self:_ask_load_backup("no_progress", true)
		end
	end
end