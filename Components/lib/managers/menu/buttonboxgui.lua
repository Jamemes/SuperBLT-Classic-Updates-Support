ButtonBoxGui = ButtonBoxGui or class(TextBoxGui)

function ButtonBoxGui:_create_text_box(ws, title, text, content_data, config)
	self._ws = ws
	self._init_layer = self._ws:panel():layer()

	if alive(self._text_box) then
		ws:panel():remove(self._text_box)

		self._text_box = nil
	end

	if self._info_box then
		self._info_box:close()

		self._info_box = nil
	end

	self._text_box_focus_button = nil
	local scaled_size = managers.gui_data:scaled_size()
	local type = config and config.type
	local preset = type and self.PRESETS[type]
	local stats_list = content_data and content_data.stats_list
	local stats_text = content_data and content_data.stats_text
	local button_list = content_data and content_data.button_list
	local focus_button = content_data and content_data.focus_button
	local use_indicator = config and config.use_indicator or false
	local no_close_legend = config and config.no_close_legend
	local no_scroll_legend = config and config.no_scroll_legend
	self._no_scroll_legend = true
	local only_buttons = config and config.only_buttons
	local use_minimize_legend = config and config.use_minimize_legend or false
	local w = preset and preset.w or config and config.w or scaled_size.width / 2.25
	local h = preset and preset.h or config and config.h or scaled_size.height / 2
	local x = preset and preset.x or config and config.x or 0
	local y = preset and preset.y or config and config.y or 0
	local bottom = preset and preset.bottom or config and config.bottom
	local left_marigin = preset and preset.left_marigin or config and config.left_marigin or 0
	local right_marigin = preset and preset.right_marigin or config and config.right_marigin or 0
	local top_marigin = preset and preset.top_marigin or config and config.top_marigin or 0
	local bottom_marigin = preset and preset.bottom_marigin or config and config.bottom_marigin or 0
	local forced_h = preset and preset.forced_h or config and config.forced_h or false
	local title_font = preset and preset.title_font or config and config.title_font or tweak_data.menu.pd2_large_font
	local title_font_size = preset and preset.title_font_size or config and config.title_font_size or 28
	local font = preset and preset.font or config and config.font or tweak_data.menu.pd2_medium_font
	local font_size = preset and preset.font_size or config and config.font_size or tweak_data.menu.pd2_medium_font_size
	local use_text_formating = preset and preset.use_text_formating or config and config.use_text_formating or false
	local text_formating_color = preset and preset.text_formating_color or config and config.text_formating_color or Color.white
	local text_formating_color_table = preset and preset.text_formating_color_table or config and config.text_formating_color_table or nil
	local is_title_outside = preset and preset.is_title_outside or config and config.is_title_outside or false
	local text_blend_mode = preset and preset.text_blend_mode or config and config.text_blend_mode or "normal"
	self._allow_moving = config and config.allow_moving or false
	local preset_or_config_y = y ~= 0
	self._toggle_button_list = {}

	if button_list then
		for index, button in ipairs(button_list) do
			if button.toggle then
				self._toggle_button_list[index] = button.initial_toggle_state
			end
		end
	end

	title = title and utf8.to_upper(title)

	if text then
		-- Nothing
	end

	local main = ws:panel():panel({
		valign = "center",
		visible = self._visible,
		x = x,
		y = y,
		w = w,
		h = h,
		layer = self._init_layer
	})
	self._panel = main
	self._panel_h = self._panel:h()
	self._panel_w = self._panel:w()
	local title_text = main:text({
		word_wrap = false,
		name = "title",
		halign = "left",
		wrap = false,
		align = "left",
		vertical = "top",
		valign = "top",
		rotation = 360,
		layer = 1,
		text = title or "none",
		visible = title and true or false,
		font = title_font,
		font_size = title_font_size,
		x = 10 + left_marigin,
		y = 10 + top_marigin
	})
	local _, _, tw, th = title_text:text_rect()

	title_text:set_size(tw, th)

	th = th + 10

	if is_title_outside then
		th = 0
	end

	self._indicator = main:bitmap({
		texture = "guis/textures/icon_loading",
		name = "indicator",
		layer = 1,
		visible = use_indicator
	})

	self._indicator:set_right(main:w())

	local top_line = main:bitmap({
		texture = "guis/textures/headershadow",
		name = "top_line",
		y = 0,
		layer = 0,
		color = Color.white,
		w = main:w()
	})

	top_line:set_bottom(th)

	local bottom_line = main:bitmap({
		texture = "guis/textures/headershadow",
		name = "bottom_line",
		y = 100,
		rotation = 180,
		layer = 0,
		color = Color.white,
		w = main:w()
	})

	bottom_line:set_top(main:h() - th)
	top_line:hide()
	bottom_line:hide()

	local lower_static_panel = main:panel({
		name = "lower_static_panel",
		h = 0,
		y = 0,
		x = 0,
		layer = 0,
		w = main:w()
	})

	self:_create_lower_static_panel(lower_static_panel)

	local info_area = main:panel({
		name = "info_area",
		y = 0,
		x = 0,
		layer = 0,
		w = main:w(),
		h = main:h() - th * 2
	})
	local info_bg = info_area:rect({
		valign = "grow",
		name = "info_bg",
		halign = "grow",
		layer = 0,
		color = tweak_data.screen_colors.dark_bg
	})
	local buttons_panel = self:_setup_buttons_panel(info_area, button_list, focus_button, only_buttons)
	local scroll_panel = info_area:panel({
		name = "scroll_panel",
		layer = 1,
		x = 10 + left_marigin,
		y = math.round(th + 5) + top_marigin,
		w = info_area:w() - 20 - (left_marigin + right_marigin),
		h = info_area:h() - (top_marigin + bottom_marigin)
	})
	local has_stats = stats_list and #stats_list > 0
	local stats_panel = self:_setup_stats_panel(scroll_panel, stats_list, stats_text)
	local text = scroll_panel:text({
		word_wrap = true,
		name = "text",
		wrap = true,
		align = "left",
		halign = "left",
		vertical = "top",
		valign = "top",
		layer = 1,
		text = text or "none",
		visible = text and true or false,
		w = scroll_panel:w() - math.round(stats_panel:w()) - (has_stats and 20 or 0),
		x = math.round(stats_panel:w()) + (has_stats and 20 or 0),
		font = font,
		font_size = font_size,
		blend_mode = text_blend_mode
	})

	if use_text_formating then
		local text_string = text:text()
		local text_dissected = utf8.characters(text_string)
		local idsp = Idstring("#")
		local start_ci = {}
		local end_ci = {}
		local first_ci = true

		for i, c in ipairs(text_dissected) do
			if Idstring(c) == idsp then
				local next_c = text_dissected[i + 1]

				if next_c and Idstring(next_c) == idsp then
					if first_ci then
						table.insert(start_ci, i)
					else
						table.insert(end_ci, i)
					end

					first_ci = not first_ci
				end
			end
		end

		if #start_ci == #end_ci then
			for i = 1, #start_ci do
				start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
				end_ci[i] = end_ci[i] - (i * 4 - 1)
			end
		end

		text_string = string.gsub(text_string, "##", "")

		text:set_text(text_string)
		text:clear_range_color(1, utf8.len(text_string))

		if #start_ci ~= #end_ci then
			Application:error("TextBoxGui: Not even amount of ##'s in skill description string!", #start_ci, #end_ci)
		else
			for i = 1, #start_ci do
				text:set_range_color(start_ci[i], end_ci[i], text_formating_color_table and text_formating_color_table[i] or text_formating_color)
			end
		end
	end

	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")

	scroll_panel:grow(-rect[3], 0)
	text:set_w(scroll_panel:w())

	local _, _, ttw, tth = text:text_rect()

	text:set_h(tth)
	scroll_panel:set_h(forced_h or math.min(h - th, tth))

	if self._override_info_area_size then
		self:_override_info_area_size(info_area, scroll_panel, buttons_panel)
	else
		info_area:set_h(scroll_panel:bottom() + buttons_panel:h() + 10 + 5 + lower_static_panel:h())
	end

	buttons_panel:set_bottom(info_area:h() - 10)

	if not preset_or_config_y then
		main:set_h(info_area:h())

		if content_data.clamp_to_screen then
			main:set_h(math.min(info_area:h(), main:parent():h() * 0.9))
			main:set_center_y(main:parent():h() / 2)
		end

		if bottom then
			main:set_bottom(bottom)
		elseif y == 0 then
			main:set_center_y(main:parent():h() / 2)
		end
	end

	top_line:set_world_bottom(scroll_panel:world_top())
	bottom_line:set_world_top(scroll_panel:world_bottom())
	lower_static_panel:set_bottom(buttons_panel:top() - 2)
	self:_setup_scroll_bar(main, scroll_panel, buttons_panel, top_line, bottom_line)

	self._info_box = BoxGuiObject:new(info_area, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	local legend_minimize = main:text({
		text = "MINIMIZE",
		name = "legend_minimize",
		halign = "left",
		valign = "top",
		layer = 1,
		visible = use_minimize_legend,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, lw, lh = legend_minimize:text_rect()

	legend_minimize:set_size(lw, lh)
	legend_minimize:set_bottom(top_line:bottom() - 4)
	legend_minimize:set_right(top_line:right())

	local legend_close = main:text({
		text = "CLOSE",
		name = "legend_close",
		halign = "left",
		valign = "top",
		layer = 1,
		visible = not no_close_legend,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, lw, lh = legend_close:text_rect()

	legend_close:set_size(lw, lh)
	legend_close:set_top(bottom_line:top() + 4)

	local legend_scroll = main:text({
		text = "SCROLL WITH",
		name = "legend_scroll",
		halign = "right",
		valign = "top",
		layer = 1,
		visible = not no_scroll_legend,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, lw, lh = legend_scroll:text_rect()

	legend_scroll:set_size(lw, lh)
	legend_scroll:set_righttop(scroll_panel:right(), bottom_line:top() + 4)

	self._scroll_panel = scroll_panel
	self._text_box = main

	self:_set_scroll_indicator()

	if is_title_outside then
		title_text:set_bottom(0)
		title_text:set_rotation(360)

		self._is_title_outside = is_title_outside
	end

	return main
end

function ButtonBoxGui:_setup_buttons_panel(info_area, button_list, focus_button, only_buttons)
	self._button_list = button_list
	local has_buttons = button_list and #button_list > 0
	local buttons_panel = info_area:panel({
		name = "buttons_panel",
		x = 10,
		layer = 1,
		w = has_buttons and 200 or 0,
		h = info_area:h()
	})

	buttons_panel:set_right(info_area:w())

	self._text_box_buttons_panel = buttons_panel
	self._info_area = info_area

	if has_buttons then
		local button_text_config = {
			name = "button_text",
			vertical = "center",
			word_wrap = "true",
			wrap = "true",
			blend_mode = "add",
			halign = "right",
			x = 10,
			layer = 2,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		}
		local max_w = 0
		local max_h = 0

		if button_list then
			for i, button in ipairs(button_list) do
				local button_panel = buttons_panel:panel({
					halign = "grow",
					h = 20,
					y = 100,
					name = button.id_name
				})
				button_text_config.text = utf8.to_upper(button.text or "")

				if button_text_config.text == "" then
					button_text_config.text = " "
				end

				local text = button_panel:text(button_text_config)
				local _, _, w, h = text:text_rect()
				max_w = math.max(max_w, w)
				max_h = math.max(max_h, h)

				text:set_size(w, h)
				button_panel:set_h(h)
				text:set_right(button_panel:w())
				button_panel:set_bottom(i * h)
			end

			buttons_panel:set_h(#button_list * max_h)
			buttons_panel:set_bottom(info_area:h() - 10)
		end

		buttons_panel:set_w(only_buttons and info_area:w() or math.max(max_w, 120) + 40)
		buttons_panel:set_right(info_area:w() - 10)

		local selected = buttons_panel:rect({
			blend_mode = "add",
			name = "selected",
			alpha = 0.3,
			color = tweak_data.screen_colors.button_stage_3
		})

		self:set_focus_button(focus_button, false)
	end

	return buttons_panel
end

function TextBoxGui:_setup_scroll_bar(main, scroll_panel, buttons_panel, top_line, bottom_line)
	local scroll_up_indicator_shade = main:panel({
		halign = "right",
		name = "scroll_up_indicator_shade",
		valign = "top",
		y = 100,
		layer = 5,
		x = scroll_panel:x(),
		w = main:w() - buttons_panel:w()
	})
	local scroll_down_indicator_shade = main:panel({
		halign = "right",
		name = "scroll_down_indicator_shade",
		valign = "bottom",
		y = 100,
		layer = 5,
		x = scroll_panel:x(),
		w = main:w() - buttons_panel:w()
	})

	scroll_up_indicator_shade:set_w(scroll_panel:w())
	scroll_down_indicator_shade:set_w(scroll_panel:w())
	scroll_up_indicator_shade:set_top(top_line:bottom())
	scroll_down_indicator_shade:set_bottom(bottom_line:top())

	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_up_indicator_arrow = main:bitmap({
		name = "scroll_up_indicator_arrow",
		layer = 3,
		halign = "right",
		valign = "top",
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_up_indicator_arrow:set_lefttop(scroll_panel:right() + 2, scroll_up_indicator_shade:top() + 8)

	local scroll_down_indicator_arrow = main:bitmap({
		name = "scroll_down_indicator_arrow",
		layer = 3,
		halign = "right",
		valign = "bottom",
		rotation = 180,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_down_indicator_arrow:set_leftbottom(scroll_panel:right() + 2, scroll_down_indicator_shade:bottom() - 8)
	BoxGuiObject:new(scroll_up_indicator_shade, {
		sides = {
			0,
			0,
			2,
			0
		}
	}):set_aligns("scale", "scale")
	BoxGuiObject:new(scroll_down_indicator_shade, {
		sides = {
			0,
			0,
			0,
			2
		}
	}):set_aligns("scale", "scale")

	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()
	local scroll_bar = main:panel({
		name = "scroll_bar",
		halign = "right",
		w = 4,
		layer = 4,
		h = bar_h
	})
	self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar, {
		sides = {
			2,
			2,
			0,
			0
		}
	})

	self._scroll_bar_box_class:set_aligns("scale", "scale")
	scroll_bar:set_w(8)
	scroll_bar:set_bottom(scroll_down_indicator_arrow:top())
	scroll_bar:set_center_x(scroll_down_indicator_arrow:center_x())
end

function ButtonBoxGui:_override_info_area_size(info_area, scroll_panel, buttons_panel)
	info_area:set_h(math.min(scroll_panel:bottom() + buttons_panel:h() + 10 + 5, 620))

	local text = scroll_panel:child("text")

	if info_area:h() < buttons_panel:h() + scroll_panel:y() + text:h() then
		text:grow(-buttons_panel:w(), 0)

		local _, _, ttw, tth = text:text_rect()

		text:set_h(tth)
	end
end

function ButtonBoxGui:set_focus_button(focus_button, allow_callbacks)
	if focus_button ~= self._text_box_focus_button then
		managers.menu:post_event("highlight")

		if self._text_box_focus_button then
			self:_set_button_selected(self._text_box_focus_button, false)
		end

		self:_set_button_selected(focus_button, true, allow_callbacks)

		self._text_box_focus_button = focus_button
	end
end

function ButtonBoxGui:_set_button_selected(index, is_selected, allow_callbacks)
	ButtonBoxGui.super._set_button_selected(self, index, is_selected)

	if allow_callbacks == nil then
		allow_callbacks = true
	end

	local button = self._button_list and self._button_list[index]

	if button and is_selected then
		if allow_callbacks and button.focus_callback_func then
			button.focus_callback_func()
		end

		local button_panel = nil

		if button.id_name then
			button_panel = self._text_box_buttons_panel:child(button.id_name)
		else
			button_panel = self._text_box_buttons_panel:children()[index]
		end

		if button_panel then
			local top = self._text_box_buttons_panel:top() + button_panel:top()
			local bottom = self._text_box_buttons_panel:top() + button_panel:bottom()
			local padding = 10
			local y_top = padding
			local y_bottom = self._info_area:h() - padding
			local new_y = self._text_box_buttons_panel:y()

			if top < y_top then
				new_y = new_y - top + y_top
			elseif y_bottom < bottom then
				new_y = new_y - bottom + y_bottom
			end

			self._text_box_buttons_panel:set_y(new_y)
		end
	end
end

function ButtonBoxGui:change_focus_button(change, override_at)
	local button_count = self._text_box_buttons_panel:num_children() - 1
	local focus_button = ((override_at or self._text_box_focus_button) + change) % button_count

	if focus_button == 0 then
		focus_button = button_count
	end

	if self._button_list[focus_button].no_selection then
		self:change_focus_button(change, focus_button)

		return
	end

	self:set_focus_button(focus_button)
end

function ButtonBoxGui:_scroll_buttons(direction)
	local SCROLL_SPEED = 28
	local speed = SCROLL_SPEED * TimerManager:main():delta_time() * 200
	local new_y = self._text_box_buttons_panel:y() + speed * direction
	local padding = 10

	if self._text_box_buttons_panel:h() > self._info_area:h() - 2 * padding then
		new_y = math.clamp(new_y, self._info_area:h() - self._text_box_buttons_panel:h() - padding, padding)
	else
		new_y = self._info_area:h() - self._text_box_buttons_panel:h() - padding
	end

	self._text_box_buttons_panel:set_y(new_y)
end

function ButtonBoxGui:mouse_wheel_up(x, y)
	local used = ButtonBoxGui.super.mouse_wheel_up(self, x, y)

	if not used and self._text_box_buttons_panel:inside(x, y) then
		self:_scroll_buttons(1)

		used = true
	end

	return used
end

function ButtonBoxGui:mouse_wheel_down(x, y)
	local used = ButtonBoxGui.super.mouse_wheel_down(self, x, y)

	if not used and self._text_box_buttons_panel:inside(x, y) then
		self:_scroll_buttons(-1)

		used = true
	end

	return used
end