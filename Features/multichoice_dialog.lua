local F = table.remove(RequiredScript:split("/"))
if F == "menuinput" then
	local function popup_choice(self, row_item)
		local dialog_data = {
			title = row_item.gui_text:text(),
			text = "",
			button_list = {}
		}

		for _, option in pairs(self:options()) do
			local text = option:parameters().text_id

			if option:parameters().localize == nil or option:parameters().localize then
				text = managers.localization:text(text)
			end

			table.insert(dialog_data.button_list, {
				text = text,
				callback_func = function ()
					self:set_value(option:parameters().value)
				end
			})
		end

		local divider = {
			no_text = true,
			no_selection = true
		}
		table.insert(dialog_data.button_list, divider)

		local no_button = {
			text = managers.localization:text("dialog_cancel"),
			cancel_button = true
		}

		table.insert(dialog_data.button_list, no_button)
		
		dialog_data.image_blend_mode = "normal"
		dialog_data.text_blend_mode = "add"
		dialog_data.use_text_formating = true
		dialog_data.w = 480
		dialog_data.h = 532
		dialog_data.title_font = tweak_data.menu.pd2_medium_font
		dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
		dialog_data.font = tweak_data.menu.pd2_small_font
		dialog_data.font_size = tweak_data.menu.pd2_small_font_size
		dialog_data.text_formating_color = Color.white
		dialog_data.text_formating_color_table = {}
		dialog_data.clamp_to_screen = true

		managers.system_menu:show_buttons(dialog_data)
	end

	Hooks:PostHook(MenuInput, "mouse_pressed", "SBLT_CUS.MenuInput.mouse_pressed.popup_choice", function(self, o, button, x, y)
		if button == Idstring("0") and managers.menu_component:input_focus() ~= true then
			local node_gui = managers.menu:active_menu() and managers.menu:active_menu().renderer and managers.menu:active_menu().renderer:active_node_gui()
			if node_gui and not node_gui.CUSTOM_MOUSE_INPUT then
				for _, row_item in pairs(node_gui.row_items) do
					local x, y = self:_modified_mouse_pos(x, y)
					if type(row_item.item.popup_choice) ~= "function" and row_item.type == "multi_choice" and row_item.choice_panel:inside(x, y) and row_item.item:enabled() then
						popup_choice(row_item.item, row_item)
						self:post_event("selection_next")
						self._logic:trigger_item(true, row_item.item)
					end
				end
			end
		end
	end)
elseif F == "textboxgui" then
	require("lib/managers/menu/ButtonBoxGui")
elseif F == "systemmenumanager" then
	core:module("SystemMenuManager")
	if type(GenericSystemMenuManager.show_buttons) ~= "function" then
		ButtonsDialog = ButtonsDialog or class(GenericDialog)
		function ButtonsDialog:init(manager, data, is_title_outside)
			GenericDialog.init(self, manager, data, is_title_outside)
			if not self._data.focus_button then
				if #self._button_text_list > 0 then
					self._data.focus_button = #self._button_text_list
				else
					self._data.focus_button = 1
				end
			end
			self._ws = self._data.ws or manager:_get_ws()
			self._panel_script = _G.ButtonBoxGui:new(self._ws, self._data.title or "", self._data.text or "", self._data, {
				type = "system_menu",
				no_close_legend = true,
				use_indicator = data.indicator or data.no_buttons,
				is_title_outside = is_title_outside
			})
			self._panel_script:add_background()
			self._panel_script:set_layer(_G.tweak_data.gui.DIALOG_LAYER)
			self._panel_script:set_centered()
			self._panel_script:set_fade(0)
			self._controller = self._data.controller or manager:_get_controller()
			self._confirm_func = callback(self, self, "button_pressed_callback")
			self._cancel_func = callback(self, self, "dialog_cancel_callback")
			self._resolution_changed_callback = callback(self, self, "resolution_changed_callback")
			managers.viewport:add_resolution_changed_func(self._resolution_changed_callback)
			if data.counter then
				self._counter = data.counter
				self._counter_time = self._counter[1]
			end
		end
	
		GenericSystemMenuManager.BUTTON_DIALOG_CLASS = ButtonsDialog
		GenericSystemMenuManager.GENERIC_BUTTON_DIALOG_CLASS = ButtonsDialog

		function GenericSystemMenuManager:show_buttons(data)
			local success = self:_show_class(data, self.GENERIC_BUTTON_DIALOG_CLASS, self.BUTTON_DIALOG_CLASS, data.force)

			self:_show_result(success, data)
		end
	end
end