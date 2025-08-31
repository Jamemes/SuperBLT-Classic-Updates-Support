-- local F = table.remove(RequiredScript:split("/"))
if F == "menumanager" then
	function MenuCallbackHandler:tap_to_interact_choice(item)
		local setting = item:value()

		managers.user:set_setting("tap_to_interact", setting, nil)
	end

	function MenuCallbackHandler:tap_to_interact_time_set(item)
		managers.user:set_setting("tap_to_interact_time", item:value(), nil)
	end

	function MenuCallbackHandler:tap_to_interact_show_text_toggle(item)
		local state = item:value() == "on"

		managers.user:set_setting("tap_to_interact_show_text", state, nil)
	end
	
	-- local tap_choice_setting = nil
	-- local tap_to_interact = node:item("tap_to_interact_choice")

	-- if tap_to_interact then
		-- tap_choice_setting = managers.user:get_setting("tap_to_interact")

		-- if tap_choice_setting then
			-- tap_to_interact:set_value(tap_choice_setting)
		-- end
	-- end

	-- local tap_to_interact_time = node:item("tap_to_interact_time_set")

	-- if tap_to_interact_time then
		-- local setting = managers.user:get_setting("tap_to_interact_time")

		-- if setting then
			-- tap_to_interact_time:set_value(setting)
		-- end
	-- end

	-- option_value = "off"
	-- local tap_to_interact_show_text = node:item("tap_to_interact_show_text_toggle")

	-- if tap_to_interact_show_text then
		-- if managers.user:get_setting("tap_to_interact_show_text") then
			-- option_value = "on"
		-- end

		-- tap_to_interact_show_text:set_value(option_value)
	-- end
elseif F == "usermanager" then
	Hooks:PostHook(GenericUserManager, "setup_setting_map", "GenericUserManager.setup_setting_map.tap_to_interact", function(self)
		self:setup_setting(106, "tap_to_interact", "off")
		self:setup_setting(107, "tap_to_interact_time", 1)
		self:setup_setting(108, "tap_to_interact_show_text", false)
	end)
	
	Hooks:PostHook(GenericUserManager, "setup_setting_map", "GenericUserManager.reset_controls_setting_map.tap_to_interact", function(self)
		self:set_setting("tap_to_interact", self:get_default_setting("tap_to_interact"))
		self:set_setting("tap_to_interact_time", self:get_default_setting("tap_to_interact_time"))
	end)
end