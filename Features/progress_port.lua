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

function MenuCallbackHandler:port_progress_from_savefile_call()
	managers.savefile:iterate_savefiles(function(result_data)
		managers.savefile:port_progress_dialog(result_data)
	end)
end

Hooks:PostHook(MenuManager, "do_clear_progress", "SBLT_CUS.MenuManager.do_clear_progress.reset_stashed_items", function()
	if Global.save_slots and Global.save_slots[Global.save_slots.current_slot] then
		Global.save_slots[Global.save_slots.current_slot].stashed_items = {}
	end
end)