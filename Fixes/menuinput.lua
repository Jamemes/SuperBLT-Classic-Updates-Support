Hooks:PostHook(MenuInput, "init", "add_MenuItemInput.TYPE", function(self)
	if not self._item_input_action_map[MenuItemInput.TYPE] then
		self._item_input_action_map[MenuItemInput.TYPE] = callback(self, self, "input_item")
	end
end)

function MenuInput:set_back_enabled(enabled)
	self._back_disabled = not enabled
end

local data = MenuInput.back
function MenuInput:back(...)
	if self._back_disabled then
		return
	end
	
	data(self, ...)
end