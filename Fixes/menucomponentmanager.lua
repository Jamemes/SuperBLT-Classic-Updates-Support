SBLT_CUS:require("lib/managers/menu/items/MenuItemInput")
SBLT_CUS:require("lib/managers/menu/ExtendedUiElemets")
SBLT_CUS:require("lib/managers/hud/HudChallengeNotification")
SBLT_CUS:require("lib/managers/menu/MenuInitiatorBase")
SBLT_CUS:require("lib/managers/menu/MenuGuiComponent")
SBLT_CUS:require("lib/managers/menu/MenuGuiComponentGeneric")
SBLT_CUS:require("lib/managers/menu/MultiProfileItemGui")
SBLT_CUS:require("lib/managers/menu/NewHeistsGui")
SBLT_CUS:require("lib/managers/menu/SearchBoxGuiObject")

if type(MenuComponentManager.run_on_all_live_components) == "function" then
	return
end

Hooks:PreHook(MenuComponentManager, "init", "_alive_components_adder", function(self)
	self._alive_components = {}
end)

function MenuComponentManager:input_focut_game_chat_gui()
	return self._game_chat_gui and self._game_chat_gui:input_focus() == true
end

function MenuComponentManager:register_component(id, component, priority)
	for i, comp_data in ipairs(self._alive_components) do
		if comp_data.id == id then
			return false
		end
	end

	table.insert(self._alive_components, {
		id = id,
		component = component,
		priority = priority or 0
	})
	table.sort(self._alive_components, function (a, b)
		return a.priority < b.priority
	end)
end

function MenuComponentManager:unregister_component(id)
	for i, comp_data in ipairs(self._alive_components) do
		if comp_data.id == id then
			table.remove(self._alive_components, i)

			return true
		end
	end

	return false
end

function MenuComponentManager:run_on_all_live_components(func, ...)
	for idx, comp_data in ipairs(self._alive_components) do
		if comp_data.component[func] then
			comp_data.component[func](comp_data.component, ...)
		end
	end
end

function MenuComponentManager:run_return_on_all_live_components(func, ...)
	for idx, comp_data in ipairs(self._alive_components) do
		if comp_data.component[func] then
			local data = {
				comp_data.component[func](comp_data.component, ...)
			}

			if data[1] ~= nil then
				return true, data
			end
		end
	end

	return nil
end

Hooks:PostHook(MenuComponentManager, "update", "run_return_on_all_live_components_update", function(self, t, dt)
	self:run_on_all_live_components("update", t, dt)
end)

Hooks:PostHook(MenuComponentManager, "accept_input", "run_return_on_all_live_components_accept_input", function(self, accept)
	self:run_on_all_live_components("accept_input", accept)
end)

Hooks:PostHook(MenuComponentManager, "input_focus", "run_return_on_all_live_components_input_focus", function(self)
	local used, values = self:run_return_on_all_live_components("input_focus")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "scroll_up", "run_return_on_all_live_components_scroll_up", function(self)
	local used, values = self:run_return_on_all_live_components("scroll_up")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "scroll_down", "run_return_on_all_live_components_scroll_down", function(self)
	local used, values = self:run_return_on_all_live_components("scroll_down")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "move_up", "run_return_on_all_live_components_move_up", function(self)
	local used, values = self:run_return_on_all_live_components("move_up")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "move_down", "run_return_on_all_live_components_move_down", function(self)
	local used, values = self:run_return_on_all_live_components("move_down")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "move_left", "run_return_on_all_live_components_move_left", function(self)
	local used, values = self:run_return_on_all_live_components("move_left")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "move_right", "run_return_on_all_live_components_move_right", function(self)
	local used, values = self:run_return_on_all_live_components("move_right")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "next_page", "run_return_on_all_live_components_next_page", function(self)
	local used, values = self:run_return_on_all_live_components("next_page")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "previous_page", "run_return_on_all_live_components_previous_page", function(self)
	local used, values = self:run_return_on_all_live_components("previous_page")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "confirm_pressed", "run_return_on_all_live_components_confirm_pressed", function(self)
	local used, values = self:run_return_on_all_live_components("confirm_pressed")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "back_pressed", "run_return_on_all_live_components_back_pressed", function(self)
	local used, values = self:run_return_on_all_live_components("back_pressed")

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "special_btn_pressed", "run_return_on_all_live_components_special_btn_pressed", function(self, ...)
	local used, values = self:run_return_on_all_live_components("special_btn_pressed", ...)

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "special_btn_released", "run_return_on_all_live_components_special_btn_released", function(self, ...)
	local used, values = self:run_return_on_all_live_components("special_btn_released", ...)

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "mouse_pressed", "run_return_on_all_live_components_mouse_pressed", function(self, o, button, x, y)
	local used, values = nil

	if button == Idstring("mouse wheel down") then
		used, values = self:run_return_on_all_live_components("mouse_wheel_down", x, y)
	elseif button == Idstring("mouse wheel up") then
		used, values = self:run_return_on_all_live_components("mouse_wheel_up", x, y)
	else
		used, values = self:run_return_on_all_live_components("mouse_pressed", button, x, y)
	end

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "mouse_clicked", "run_return_on_all_live_components_mouse_clicked", function(self, o, button, x, y)
	local used, values = self:run_return_on_all_live_components("mouse_clicked", o, button, x, y)

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "mouse_double_click", "run_return_on_all_live_components_mouse_double_click", function(self, o, button, x, y)
	local used, values = self:run_return_on_all_live_components("mouse_double_click", o, button, x, y)

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "mouse_released", "run_return_on_all_live_components_mouse_released", function(self, o, button, x, y)
	local used, values = self:run_return_on_all_live_components("mouse_released", o, button, x, y)

	if used then
		return unpack(values)
	end
end)

Hooks:PostHook(MenuComponentManager, "mouse_moved", "run_return_on_all_live_components_mouse_moved", function(self, o, x, y)
	local used, values = self:run_return_on_all_live_components("mouse_moved", o, x, y)

	if used then
		local _, pointer = unpack(values)

		return true, pointer or "arrow"
	end
end)