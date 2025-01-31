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

function MenuInput:mouse_pressed(o, button, x, y)
	if not self._accept_input then
		return
	end

	if managers.blackmarket and managers.blackmarket:is_preloading_weapons() then
		return
	end

	if not managers.menu:active_menu() then
		return
	end

	self._keyboard_used = false
	x, y = self:_modified_mouse_pos(x, y)

	if button == Idstring("0") and managers.menu_component:input_focus() ~= true then
		local node_gui = managers.menu:active_menu().renderer:active_node_gui()

		if not node_gui or node_gui._listening_to_input then
			return
		end

		if node_gui and not node_gui.CUSTOM_MOUSE_INPUT then
			for _, row_item in pairs(node_gui.row_items) do
				if row_item.item:parameters().pd2_corner then
					if row_item.gui_text:inside(x, y) then
						local item = self._logic:selected_item()

						if item then
							self._item_input_action_map[item.TYPE](item, self._controller, true)

							return node_gui.mouse_pressed and node_gui:mouse_pressed(button, x, y)
						end
					end
				elseif row_item.gui_panel:inside(x, y) and node_gui._item_panel_parent:inside(x, y) then
					if row_item.no_mouse_select then
					elseif row_item.type == "slider" then
						self:post_event("slider_grab")

						if row_item.gui_slider_marker:inside(x, y) then
							self._slider_marker = {
								button = button,
								item = row_item.item,
								row_item = row_item
							}
						elseif row_item.gui_slider:inside(x, y) then
							local where = (x - row_item.gui_slider:world_left()) / (row_item.gui_slider:world_right() - row_item.gui_slider:world_left())
							local item = row_item.item

							if item:enabled() then
								item:set_value_by_percentage(where * 100)
								self._logic:trigger_item(true, item)

								self._slider_marker = {
									button = button,
									item = row_item.item,
									row_item = row_item
								}
							end
						end
					elseif row_item.type == "kitslot" then
						local item = self._logic:selected_item()

						if row_item.arrow_right:inside(x, y) then
							item:next()
							self._logic:trigger_item(true, item)

							if row_item.arrow_right:visible() then
								self:post_event("selection_next")
							end
						elseif row_item.arrow_left:inside(x, y) then
							item:previous()
							self._logic:trigger_item(true, item)

							if row_item.arrow_left:visible() then
								self:post_event("selection_previous")
							end
						elseif not row_item.choice_panel:inside(x, y) then
							self._item_input_action_map[item.TYPE](item, self._controller, true)

							return node_gui.mouse_pressed and node_gui:mouse_pressed(button, x, y)
						end
					elseif row_item.type == "grid" then
						local item = self._logic:selected_item()

						if row_item.item == item then
							row_item.item:mouse_pressed(button, x, y, row_item)
						end
					elseif row_item.type == "multi_choice" then
						local item = row_item.item

						if row_item.arrow_right:inside(x, y) then
							if item:next() then
								self:post_event("selection_next")
								self._logic:trigger_item(true, item)
							end
						elseif row_item.arrow_left:inside(x, y) then
							if item:previous() then
								self:post_event("selection_previous")
								self._logic:trigger_item(true, item)
							end
						elseif row_item.gui_text:inside(x, y) then
							if row_item.align == "left" then
								if item:previous() then
									self:post_event("selection_previous")
									self._logic:trigger_item(true, item)
								end
							elseif item:next() then
								self:post_event("selection_next")
								self._logic:trigger_item(true, item)
							end
						elseif row_item.choice_panel:inside(x, y) and item:enabled() then
							item:popup_choice(row_item)
							self:post_event("selection_next")
							self._logic:trigger_item(true, item)
						end
					elseif row_item.type == "chat" then
						if row_item.chat_input:inside(x, y) then
							row_item.chat_input:script().set_focus(true)
						end
					elseif row_item.type == "divider" then
					else
						local item = self._logic:selected_item()

						if item then
							self._item_input_action_map[item.TYPE](item, self._controller, true)

							return node_gui.mouse_pressed and node_gui:mouse_pressed(button, x, y)
						end
					end
				end
			end
		end
	end

	if managers.menu:active_menu().renderer:mouse_pressed(o, button, x, y) then
		return
	end

	for i, clbk in pairs(self._callback_map.mouse_pressed) do
		clbk(o, button, x, y)
	end
end
