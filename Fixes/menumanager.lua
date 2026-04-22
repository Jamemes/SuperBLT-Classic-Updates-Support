local game_ver = SBLT_CUS:game_version()
local game_update = tweak_data.updates_table[game_ver] or ""
Hooks:Add("LocalizationManagerPostInit", "SBLT_CUS_loc", function(...)
	LocalizationManager:add_localized_strings({
		menu_button_throwable = "Use Throwable",
		menu_filter_search = "Search",
		menu_button_hide = "Hide",
		menu_button_show = "Show",
		menu_port_progress = "Port the Progress",
		menu_port_progress_help = string.format("%s  (Current Update: %s)", "Choose the slot from 0 to 100.", game_update),
		menu_slot_change = "Change Progress Slot",
		menu_slot_change_text = "In the order to change the progress slot you need to restart the game. Continue?",
		menu_slot_is_forbidden_text = "This slot is used by current version of the game or gameplay overhauls.",
		menu_game_restart = "Restart the game",
		dialog_check_press_any_key_stuck = "Incompatibility of the save file",
		dialog_check_press_any_key_stuck_desc = "If you see this message, then most likely your save file is incompatible with this version of the game.\nIf you click 'Yes', you can enter the main menu despite the error, but then the game may encounter bugs that will cause errors or crashes that interfere with the game.\nTo fix this, you need to change the save file in the game settings in the 'Progress Slot' item, type the number of the desired slot or click 'Quit' and type it in the file 'PROGRESS_SLOT.txt' after game version numbers - ".. game_ver .. ".\n\nWhat you choose?",
	})

	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			menu_button_throwable = "Использовать метательное",
			menu_filter_search = "Поиск",
			menu_button_hide = "Скрыть",
			menu_button_show = "Показать",
			menu_port_progress = "Слот прогресса",
			menu_port_progress_help = string.format("%s  (Эта версия: %s)", "Выберите слот с 0 по 100.", game_update),
			menu_slot_change = "Портировать прогресс",
			menu_slot_change_text = "Чтобы изменить слот прогресса вам нужно перезапустить игру. Продолжить?",
			menu_slot_is_forbidden_text = "Этот слот используется актуальной версией игры или модификациями.",
			menu_game_restart = "Перезапустить игру",
			dialog_check_press_any_key_stuck = "Несовместимость файла сохренения",
			dialog_check_press_any_key_stuck_desc = "Если вы видите это сообщение, то скорее всего ваш файл сохренений несовместим с данной версией игры.\nЕсли вы нажмете 'Да', вы можете войти в главное меню не смотря на ошибку, но тогда в игре могут встретятся баги, которые будут вызывать ошибки или вылеты мешающие играть.\nЧтобы исправить это вам нужно сменить файл сохранения в настройках игры в пункте 'Слот прогресса' прописать номер нужного слота или нажать 'Выйти' и прописать в файле 'PROGRESS_SLOT.txt' вручную в строке после обозначения версии игры - ".. game_ver .. ".\n\n Что вы выбераете?",
		})
	end
end)

function MenuManager:is_steam_controller()
	return self:active_menu() and self:active_menu().input and self:active_menu().input._controller and self:active_menu().input._controller.TYPE == "steam" or managers.controller:get_default_wrapper_type() == "steam"
end

function MenuCallbackHandler:is_steam_controller()
	return managers.menu:is_steam_controller()
end

function MenuCallbackHandler:is_not_steam_controller()
	return not self:is_steam_controller()
end

MenuCustomizeControllerCreator.CONTROLS_INFO = {
	move = {
		hidden = true,
		category = "normal"
	},
	up = {
		category = "normal",
		text_id = "menu_button_move_forward"
	},
	down = {
		category = "normal",
		text_id = "menu_button_move_back"
	},
	left = {
		category = "normal",
		text_id = "menu_button_move_left"
	},
	right = {
		category = "normal",
		text_id = "menu_button_move_right"
	},
	primary_attack = {
		category = "normal",
		text_id = "menu_button_fire_weapon"
	},
	secondary_attack = {
		category = "normal",
		text_id = "menu_button_aim_down_sight"
	},
	primary_choice1 = {
		category = "normal",
		text_id = "menu_button_weapon_slot1"
	},
	primary_choice2 = {
		category = "normal",
		text_id = "menu_button_weapon_slot2"
	},
	switch_weapon = {
		category = "normal",
		text_id = "menu_button_switch_weapon"
	},
	reload = {
		category = "normal",
		text_id = "menu_button_reload"
	},
	weapon_gadget = {
		category = "normal",
		text_id = "menu_button_weapon_gadget"
	},
	run = {
		category = "normal",
		text_id = "menu_button_sprint"
	},
	jump = {
		category = "normal",
		text_id = "menu_button_jump"
	},
	duck = {
		category = "normal",
		text_id = "menu_button_crouch"
	},
	melee = {
		category = "normal",
		text_id = "menu_button_melee"
	},
	interact = {
		category = "normal",
		text_id = "menu_button_shout"
	},
	interact_secondary = {
		category = "normal",
		text_id = "menu_button_shout_secondary"
	},
	use_item = {
		category = "normal",
		text_id = "menu_button_deploy"
	},
	toggle_chat = {
		category = "normal",
		text_id = "menu_button_chat_message"
	},
	push_to_talk = {
		category = "normal",
		text_id = "menu_button_push_to_talk"
	},
	continue = {
		category = "normal",
		text_id = "menu_button_continue"
	},
	throw_grenade = {
		category = "normal",
		text_id = "menu_button_throwable"
	},
	weapon_firemode = {
		category = "normal",
		text_id = "menu_button_weapon_firemode"
	},
	cash_inspect = {
		category = "normal",
		text_id = "menu_button_cash_inspect"
	},
	deploy_bipod = {
		category = "normal",
		text_id = "menu_button_deploy_bipod"
	},
	change_equipment = {
		category = "normal",
		text_id = "menu_button_change_equipment"
	},
	toggle_hud = {
		category = "normal",
		text_id = "menu_button_toggle_hud"
	},
	drive = {
		hidden = true,
		category = "vehicle"
	},
	accelerate = {
		category = "vehicle",
		text_id = "menu_button_accelerate"
	},
	brake = {
		category = "vehicle",
		text_id = "menu_button_brake"
	},
	turn_left = {
		category = "vehicle",
		text_id = "menu_button_turn_left"
	},
	turn_right = {
		category = "vehicle",
		text_id = "menu_button_turn_right"
	},
	hand_brake = {
		category = "vehicle",
		text_id = "menu_button_handbrake"
	},
	vehicle_change_camera = {
		category = "vehicle",
		text_id = "menu_button_vehicle_change_camera"
	},
	vehicle_rear_camera = {
		category = "vehicle",
		text_id = "menu_button_vehicle_rear_camera"
	},
	vehicle_shooting_stance = {
		category = "vehicle",
		text_id = "menu_button_vehicle_shooting_stance",
		block = {
			"normal"
		}
	},
	vehicle_exit = {
		category = "vehicle",
		text_id = "menu_button_vehicle_exit"
	},
	drop_in_accept = {
		category = "normal",
		text_id = "menu_button_drop_in_accept"
	},
	drop_in_return = {
		category = "normal",
		text_id = "menu_button_drop_in_return"
	},
	drop_in_kick = {
		category = "normal",
		text_id = "menu_button_drop_in_kick"
	}
}

function MenuCustomizeControllerCreator.controls_info_by_category(category)
	local t = {}

	for _, name in ipairs(MenuCustomizeControllerCreator.CONTROLS) do
		if MenuCustomizeControllerCreator.CONTROLS_INFO[name].category == category then
			table.insert(t, name)
		end
	end

	return t
end

Hooks:PreHook(MenuNodeGui, "activate_customize_controller", "fix_skip_first_activate_key", function(self)
	self._skip_first_activate_key = true
end)