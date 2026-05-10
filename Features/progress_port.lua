Hooks:Add("MenuManagerBuildCustomMenus", "_add_port_progress_from_savefile_input", function(menu_manager, nodes)
	local node = nodes.options
	if node and nodes.main then
		local pos = 1
		for id, item in pairs(node._items) do
			if item:name() == "edit_game_settings" then
				pos = id
			end
		end
		
		table.insert(node._items, pos, node:create_item({type = "MenuItemDivider"}, {
			name = "savefilemanager_divider",
			no_text = true,
			size = 18
		}))

		local params = {
			name = "port_progress",
			text_id = "menu_port_progress",
			help_id = "menu_port_progress_help",
			callback = "port_progress_call",
		}

		local port_progress_btn = node:create_item({type = "CoreMenuItem.Item"}, params)
		port_progress_btn.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			port_progress_btn:set_callback_handler(node.callback_handler)
		end
		table.insert(node._items, pos, port_progress_btn)

		table.insert(node._items, pos, node:create_item({type = "MenuItemDivider"}, {
			name = "port_separator",
			no_text = true,
			size = 8
		}))

		local params = {
			name = "current_slot",
			text_id = "",
			help_id = "menu_change_slot_help",
			callback = "menu_change_slot_call",
			localize = false
		}

		local change_slot_btn = node:create_item({type = "CoreMenuItem.Item"}, params)
		change_slot_btn.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			change_slot_btn:set_callback_handler(node.callback_handler)
		end
		table.insert(node._items, pos, change_slot_btn)
	end
end)

function MenuCallbackHandler:port_progress_call()
	if not _G.LuaNetworking:IsMultiplayer() then
		managers.savefile:port_progress()
	end
end

function MenuCallbackHandler:menu_change_slot_call()
	if not _G.LuaNetworking:IsMultiplayer() then
		managers.savefile:change_slot(true)
	end
end

Hooks:PostHook(MenuManager, "do_clear_progress", "SBLT_CUS.MenuManager.do_clear_progress.reset_stashed_items", function()
	if Global.save_slots and Global.save_slots[Global.save_slots.current_slot] then
		Global.save_slots[Global.save_slots.current_slot].stashed_items = {}
	end
end)

Hooks:PostHook(MenuOptionInitiator, "modify_node", "SBLT_CUS.MenuOptionInitiator.modify_node.refresh_current_slot_option", function(self, node)
	local node_name = node:parameters().name
	if node_name == "options" then
		local slot = Global.save_slots.current_slot
		local item = node:item("current_slot")
		if item then
			item:set_parameter("text_id", managers.savefile:current_slot(Global.save_slots[slot], slot))
		end
	end
end)

Hooks:PostHook(MenuManager, "on_enter_lobby", "SBLT_CUS.MenuManager.on_enter_lobby.load_preserved_heist", function()
	if Global.save_slots[Global.save_slots.current_slot].job_preserved then
		MenuCallbackHandler:lobby_start_the_game()
	end
end)

Hooks:PostHook(MenuCallbackHandler, "load_start_menu_lobby", "SBLT_CUS.MenuCallbackHandler.load_start_menu_lobby.remove_preserved_heist", function()
	Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
end)

Hooks:PostHook(MenuCallbackHandler, "_dialog_end_game_yes", "SBLT_CUS.MenuCallbackHandler._dialog_end_game_yes.remove_preserved_heist", function()
	Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
end)

Hooks:PostHook(MenuCallbackHandler, "lobby_start_the_game", "SBLT_CUS.MenuCallbackHandler.lobby_start_the_game.preserve_the_heist", function()
	if not Global.save_slots[Global.save_slots.current_slot].job_preserved then
		managers.savefile:_save("lobby_reserve")
		managers.savefile._reserve_load = true
	end
end)

local data = MenuManager.show_question_start_tutorial
function MenuManager:show_question_start_tutorial(params)
	if not Global.save_slots[Global.save_slots.current_slot].job_preserved then
		data(self, params)
	end
end