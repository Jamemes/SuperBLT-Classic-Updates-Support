Hooks:Add("LocalizationManagerPostInit", "progress_slot_changer_loc", function(...)
	LocalizationManager:add_localized_strings({
		menu_PROGRESS_SLOT = "Progress Slot",
		menu_slot_change = "Change Progress Slot",
		menu_slot_change_text = "In the order to change the progress slot you need to restart the game. Continue?",
		menu_slot_is_forbidden_text = "This slot is used by current version of the game or gameplay overhauls.",
		menu_game_restart = "Restart the game",
	})

	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			menu_PROGRESS_SLOT = "Слот прогресса",
			menu_slot_change = "Сменить слот прогресса",
			menu_slot_change_text = "Чтобы изменить слот прогресса вам нужно перезапустить игру. Продолжить?",
			menu_slot_is_forbidden_text = "Этот слот используется актуальной версией игры или модификациями.",
			menu_game_restart = "Перезапустить игру",
		})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "_add_PROGRESS_SLOT_input", function(menu_manager, nodes)
	local node = nodes.options
	if node then
		local data_node = {
			type = "MenuItemInput"
		}
		local params = {
			name = "PROGRESS_SLOT",
			text_id = "menu_PROGRESS_SLOT",
			empty_gui_input_limit = 28,
			input_limit = 2,
			callback = "change_PROGRESS_SLOT_call"
		}
		local new_item = node:create_item(data_node, params)
		
		new_item.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			new_item:set_callback_handler(node.callback_handler)
		end
		
		new_item._input_text = tostring(SavefileManager.PROGRESS_SLOT)
		
		local pos = 1
		for id, item in pairs(node._items) do
			if item:name() == "edit_game_settings" then
				pos = id
			end
		end
		
		table.insert(node._items, pos, new_item)
	end
end)

local function save_progress_slots(tbl)
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

function MenuCallbackHandler:change_PROGRESS_SLOT_call(item)
	if not item._editing then
		item._input_text = item._input_text:gsub('%D', "")
		if item._input_text ~= "" and SavefileManager._forbidden_slots[item._input_text] then
			local dialog_data = {}
			dialog_data.title = SavefileManager._forbidden_slots[item._input_text]
			dialog_data.text = managers.localization:text("menu_slot_is_forbidden_text")
			local ok_button = {}
			ok_button.cancel_button = true
			ok_button.text = managers.localization:text("dialog_ok")
			dialog_data.button_list = {ok_button}
			managers.system_menu:show(dialog_data)
			item._input_text = tostring(SavefileManager.PROGRESS_SLOT)
		elseif item._input_text ~= "" and item._input_text ~= tostring(SavefileManager.PROGRESS_SLOT) and string.len(item._input_text) == 2 then
			local dialog_data = {}
			dialog_data.title = managers.localization:text("menu_slot_change")
			dialog_data.text = managers.localization:text("menu_slot_change_text")
			local yes_button = {}
			yes_button.text = managers.localization:text("menu_game_restart")
			yes_button.callback_func = function()
				SavefileManager._slots_per_version[tostring(Application:version())] = item._input_text
				PrintTable(SavefileManager._slots_per_version)
				save_progress_slots(SavefileManager._slots_per_version)
				setup:quit()
			end
			local no_button = {}
			no_button.cancel_button = true
			no_button.text = managers.localization:text("menu_back")
			no_button.callback_func = function()
				item._input_text = tostring(SavefileManager.PROGRESS_SLOT)
			end
			dialog_data.button_list = {yes_button, no_button}
			managers.system_menu:show(dialog_data)
		else
			item._input_text = tostring(SavefileManager.PROGRESS_SLOT)
		end
	end
end