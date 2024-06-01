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