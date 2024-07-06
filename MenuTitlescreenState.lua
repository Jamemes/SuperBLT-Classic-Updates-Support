local data = MenuTitlescreenState.get_start_pressed_controller_index
function MenuTitlescreenState:get_start_pressed_controller_index()
	local button = data(self)

	if tostring(button) ~= "nil" and not self._any_key_pressed then
		self._any_key_pressed = true
		
		DelayedCalls:Add("CheckPressAnyKeyStuck", 1, function()
			local dialog_data = {
				id = "check_press_any_key_stuck",
				title = managers.localization:text("dialog_check_press_any_key_stuck"),
				text = managers.localization:text("dialog_check_press_any_key_stuck_desc"),
				focus_button = 1
			}
			local yes_button = {
				text = managers.localization:text("dialog_yes"),
				callback_func = function()
					SoundDevice:create_source("MenuTitleScreen"):post_event("menu_start")
					game_state_machine:change_state_by_name("menu_main")
				end
			}
			
			local no_button = {
				text = managers.localization:text("menu_quit"),
				callback_func = function()
					setup:quit()
				end,
				cancel_button = true
			}
			
			dialog_data.button_list = {yes_button, no_button}
			managers.system_menu:show(dialog_data)
		end)
	end

	return button
end

local data = MenuTitlescreenState._load_savegames_done
function MenuTitlescreenState:_load_savegames_done()
	DelayedCalls:Remove("CheckPressAnyKeyStuck")
	if managers.system_menu:is_active_by_id("check_press_any_key_stuck") then
		managers.system_menu:close("check_press_any_key_stuck")
	end
	
	data(self)
end