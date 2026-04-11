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

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return x, y, w, h
end

SavefileManager = class()
function SavefileManager:init()
	Global.savefile_manager = Global.savefile_manager or {}
	Global.savefile_manager.save_slots = Global.savefile_manager.save_slots or {}
	Global.savefile_manager.backup_save_enabled = true

	self._workspace = managers.gui_data:create_saferect_workspace()
	self._gui = self._workspace:panel():gui(Idstring("guis/savefile_manager"))
	self._gui_script = self._gui:script()
	self._workspace:hide()

	self:load_progress()
end

function SavefileManager:save_progress(save_system)
	local save_slot = Global.savefile_manager.save_slots[game_version] or {}
	for _, class in pairs(managers_list) do
		if managers[class] then
			if type(managers[class].save) == "function"  then
				managers[class]:save(save_slot)
			end

			if type(managers[class].save_savedata) == "function"  then
				managers[class]:save_savedata(save_slot)
			end

			if type(managers[class].save_settings) == "function"  then
				managers[class]:save_settings(save_slot)
			end

			if type(managers[class].save_job_values) == "function"  then
				managers[class]:save_job_values(save_slot)
			end

			if type(managers[class].save_profile) == "function"  then
				managers[class]:save_profile(save_slot)
			end
		end
	end

	if type(SaveGameManager) == "userdata" then
		SaveGameManager:save({
			queued_in_save_manager = true,
			date_format = "%c",
			max_queue_size = 1,
			first_slot = 1,
			task_type = 3,
			subtitle = "",
			details = "",
			save_system = save_system or "steam_cloud",
			data = {Global.savefile_manager.save_slots}
		}, function() end)
	elseif type(NewSave) == "userdata" then
		local param_map = {
			save_slots = 1,
			save_system = save_system or "steam_cloud"
		}
		local save_data = NewSave:create_save_data()
		save_data:set_subtitle("")
		save_data:set_details("")
		save_data:set_information(Global.savefile_manager.save_slots)
		SavefileTaskHandler:new(NewSave:save(save_data, param_map), 3, function() end, nil, "progress")
	end

	if Global.savefile_manager.progress_loaded then
		self:show_icon(utf8.to_upper(managers.localization:text("savefile_saving")))
	end
end

function SavefileManager:get_progress_from_older_version_slot(game_ver)
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

function SavefileManager:perform_load(cache)
	Global.savefile_manager.save_slots = cache

	if not cache[game_version] then
		local donor_slot, donor_data = self:get_progress_from_older_version_slot(game_version)

		if donor_slot and donor_data then
			local old_type = "0." .. tostring(donor_slot)
			local current_type = "1." .. tostring(donor_slot)
			local game_version_str = tweak_data.updates_table[current_type] or tweak_data.updates_table[old_type] or tostring(donor_slot)
			self:show_icon(utf8.to_upper("Progress Fetched") .. "\nUpdate " .. game_version_str, true)
			make_fine_text(self._gui_script.gui_text)
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

	Global.savefile_manager.progress_loaded = true
end

function SavefileManager:load_progress(save_system)
	if type(SaveGameManager) == "userdata" then
		SaveGameManager:load({
			queued_in_save_manager = true,
			task_type = 2,
			first_slot = 1,
			save_system = save_system or "steam_cloud"
		}, function(_, result_data)
			if type_name(result_data) == "table" then
				for slot, slot_data in pairs(result_data) do
					if slot == 1 and slot_data.status == "OK" then
						self:perform_load(slot_data.data)
						Global.savefile_manager.progress_loaded = true

						break
					end
				end
			end
		end)
	elseif type(NewSave) == "userdata" then
		local task = NewSave:load({
			save_slots = 1,
			save_system = save_system or "steam_cloud"
		})

		self._task_handler = SavefileTaskHandler:new(task, 2, function(save_data)
			if save_data:status() == SaveData.OK then
				self:perform_load(save_data:information())
			end
		end, function() end)
	end
end

function SavefileManager:show_icon(text, loading)
	if self._loading_icon then
		return
	end

	self._workspace:show()
	self._loading_icon = loading
	self._hide_gui_time = nil
	self._show_gui_time = TimerManager:main():time()
	self._gui_script:set_text(text)
	self._gui_script.indicator:animate(self._gui_script.saving)
end

function SavefileManager:update(t, dt)
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
		self._loading_icon = nil
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

function SavefileManager:port_progress_from_another_savefile(slot, save_system)
	local task = NewSave:load({
		save_slots = slot,
		save_system = save_system or "steam_cloud"
	})

	self._task_handler = SavefileTaskHandler:new(task, 2, function(save_data)
		if save_data:status() == SaveData.OK then
			Global.savefile_manager.save_slots[game_version] = save_data:information()
			self:save_progress()
			setup:quit()
		end
	end, function() end)
end

function SavefileManager:is_in_loading_sequence()
	return Global.savefile_manager and not Global.savefile_manager.progress_loaded
end

function SavefileManager:is_active() end
function SavefileManager:savefile_access() end
function SavefileManager:add_load_sequence_done_callback_handler() end
function SavefileManager:setting_changed() end
function SavefileManager:add_load_done_callback() end
function SavefileManager:save_setting() end
function SavefileManager:add_active_changed_callback() end
function SavefileManager:break_loading_sequence() end
function SavefileManager:save_game() end
function SavefileManager:storage_changed() end
function SavefileManager:active_user_changed() end
function SavefileManager:check_space_required() end
function SavefileManager:fetch_savegame_hdd_space_required() end
function SavefileManager:load_settings() end
function SavefileManager:paused_update() end