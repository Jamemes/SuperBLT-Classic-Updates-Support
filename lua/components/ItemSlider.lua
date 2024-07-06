core:module("CoreMenuItemSlider")
if ItemSlider.slider_color then
	return
end

function ItemSlider:scaled_value_string()
	return string.format("%." .. self._decimal_count .. "f", self:value() * self._show_scale)
end

function ItemSlider:raw_value_string()
	return string.format("%." .. self._decimal_count .. "f", self:value())
end

function ItemSlider:value_string()
	local str = self._is_scaled and self:scaled_value_string() or self:raw_value_string()

	if self._is_percentage then
		str = str .. "%"
	end

	return str
end

function ItemSlider:set_slider_color(color)
	self._slider_color = color
end

function ItemSlider:set_slider_highlighted_color(color)
	self._slider_color_highlight = color
end

function ItemSlider:slider_color()
	return self._slider_color
end

function ItemSlider:slider_highlighted_color()
	return self._slider_color_highlight
end