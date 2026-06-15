
local F = table.remove(RequiredScript:split("/"))
if F == "menumanager" then
	Hooks:Add("MenuManagerBuildCustomMenus", "SBLT_CUS.add_quit_game_button", function(menu_manager, nodes)
		local node = nodes.main
		if node then
			local params = {
				name = "continue_the_game",
				text_id = "sblt_cus_continue_the_game",
				help_id = "sblt_cus_continue_the_game_help",
				visible_callback = "sblt_cus_show_continue_the_game_button",
				callback = "sblt_cus_continue_the_game_callback",
				font = "fonts/font_large_mf",
				font_size = 24,
			}

			local continue_btn = node:create_item({type = "CoreMenuItem.Item"}, params)
			continue_btn.dirty_callback = callback(node, node, "item_dirty")
			if node.callback_handler then
				continue_btn:set_callback_handler(node.callback_handler)
			end
			table.insert(node._items, 1, continue_btn)
		end

		local node = nodes.pause
		if node then
			table.insert(node._items, node:create_item({type = "MenuItemDivider"}, {
				name = "quit_game_divider",
				no_text = true,
				size = 24
			}))

			local params = {
				name = "quit",
				text_id = "menu_quit",
				help_id = "menu_quit_help",
				visible_callback = "show_quit_game_button_in_pause",
				callback = "quit_game",
			}

			local quit_game_btn = node:create_item({type = "CoreMenuItem.Item"}, params)
			quit_game_btn.dirty_callback = callback(node, node, "item_dirty")
			if node.callback_handler then
				quit_game_btn:set_callback_handler(node.callback_handler)
			end
			table.insert(node._items, quit_game_btn)
		end
	end)

	Hooks:PreHook(MenuCallbackHandler, "_dialog_quit_yes", "SBLT_CUS.MenuCallbackHandler._dialog_quit_yes.stop_multiplayer", function()
		managers.menu:active_menu().logic:navigate_back(true)
		if Network:multiplayer() then
			Network:set_multiplayer(false)
			managers.network:session():send_to_peers("set_peer_left")
			managers.network:queue_stop_network()
		end
	end)

	function MenuCallbackHandler:sblt_cus_show_continue_the_game_button()
		return managers.savefile.show_continue_job_button
	end

	function MenuCallbackHandler:sblt_cus_continue_the_game_callback()
		managers.savefile:preserved_job_dialog(managers.savefile.show_continue_job_button)
	end

	function MenuCallbackHandler:show_quit_game_button_in_pause()
		local state = true
		if managers.job:is_current_job_professional() then
			state = game_state_machine:current_state_name() == "ingame_waiting_for_players"
		end

		return _G.LuaNetworking:IsHost() and state
	end

	Hooks:PostHook(MenuCallbackHandler, "lobby_start_the_game", "SBLT_CUS.MenuCallbackHandler.lobby_start_the_game.preserve_the_heist", function()
		if _G.LuaNetworking:IsHost() and managers.job:current_job_id() ~= "safehouse" then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = {
				job_manager = Global.job_manager,
				game_settings = Global.game_settings,
				loot_manager = Global.loot_manager,
				asset_manager = Global.asset_manager,
				mission_manager = Global.mission_manager,
			}

			managers.savefile:_save()
		end
	end)

	Hooks:PostHook(MenuManager, "on_enter_lobby", "SBLT_CUS.MenuManager.on_enter_lobby.load_preserved_heist", function()
		if Global.save_slots[Global.save_slots.current_slot].job_preserved and managers.savefile.job_preserved then
			MenuCallbackHandler:lobby_start_the_game()
		elseif Global.save_slots[Global.save_slots.current_slot].job_preserved and not managers.savefile.preserved_job_canceled then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
			managers.savefile:_save()
		end
	end)

	Hooks:PostHook(MenuCallbackHandler, "_dialog_end_game_yes", "SBLT_CUS.MenuCallbackHandler._dialog_end_game_yes.remove_preserved_heist", function()
		if Global.save_slots[Global.save_slots.current_slot].job_preserved then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
			managers.savefile:_save()
		end
	end)

	local data = MenuManager.show_question_start_tutorial
	function MenuManager:show_question_start_tutorial(params)
		if not Global.save_slots[Global.save_slots.current_slot].job_preserved then
			data(self, params)
		end
	end

	local data = MenuManager.show_question_new_safehouse_new_player
	if type(data) == "function" then
		function MenuManager:show_question_new_safehouse_new_player(params)
			if not Global.save_slots[Global.save_slots.current_slot].job_preserved then
				data(self, params)
			end
		end
	end
elseif F == "jobmanager" then
	Hooks:PostHook(JobManager, "next_stage", "SBLT_CUS.JobManager.next_stage.job_preserve", function(self)
		if _G.LuaNetworking:IsHost() and not managers.job:is_job_finished() then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = {
				job_manager = Global.job_manager,
				game_settings = Global.game_settings,
				loot_manager = Global.loot_manager,
				asset_manager = Global.asset_manager,
				mission_manager = Global.mission_manager,
			}

			managers.savefile:_save()
		end
	end)
elseif F == "lootmanager" then
	Hooks:PostHook(LootManager, "_setup", "SBLT_CUS.LootManager._setup.apply_preserved_loot", function()
		if Global.save_slots and Global.save_slots[Global.save_slots.current_slot] and Global.save_slots[Global.save_slots.current_slot].job_preserved and managers.savefile.job_preserved then
			Global.loot_manager = Global.save_slots[Global.save_slots.current_slot].job_preserved.loot_manager
		end
	end)
end