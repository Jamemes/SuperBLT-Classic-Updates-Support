Hooks:Add("MenuManagerBuildCustomMenus", "_add_port_progress_from_savefile_input", function(menu_manager, nodes)
	local node = nodes.options
	if node and nodes.main then
		local data_node = {
			type = "CoreMenuItem.Item"
		}
		local params = {
			name = "port_progress_from_savefile",
			text_id = "menu_port_progress",
			help_id = "menu_port_progress_help",
			input_limit = 2,
			callback = "port_progress_from_savefile_call"
		}
		local new_item = node:create_item(data_node, params)
		
		new_item.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			new_item:set_callback_handler(node.callback_handler)
		end
		
		local pos = 1
		for id, item in pairs(node._items) do
			if item:name() == "edit_game_settings" then
				pos = id
			end
		end
		
		table.insert(node._items, pos, new_item)
	end
end)

function MenuCallbackHandler:port_progress_from_savefile_call(item)
	SaveGameManager:iterate_savegame_slots({
		queued_in_save_manager = true,
		task_type = 6,
		save_system = "steam_cloud",
		first_slot = 0,
		last_slot = 100
	}, function(task_data, result_data)
			
		local dialog_data = {
			title = "Progress Port",
			text = "",
			button_list = {}
		}
		
		local slot_names = {
			[98] = "Vanilla",
			[97] = "Tournament",
			[11] = "Update 24.2",
			[37] = "Update 37.1",
			[76] = "Update 76",
			[77] = "Restoration Mod",
			[24] = "Original Pack",
			[26] = "Classic Heisting",
			[21] = "Eclipse",
		}

		for slot, _ in pairs(result_data) do
			local slot_name_text = slot_names[slot] and string.format("(%s)  ", slot_names[slot]) or ""
			table.insert(dialog_data.button_list, {
				text = string.format("%s%s", slot_name_text, tostring(slot)),
				num = slot,
				callback_func = function()
					managers.savefile:port_progress_from_another_savefile(tonumber(slot))
				end,
			})
		end
		table.sort(dialog_data.button_list, function(a, b)
			return a.num > b.num
		end)

		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = managers.localization:text("menu_back"),
			cancel_button = true
		})
		

		managers.system_menu:show(dialog_data)
	end)

end