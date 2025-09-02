if type(HudIconsTweakData.get_icon_or) ~= "function" then
	function HudIconsTweakData:get_icon_or(icon_id, ...)
		local icon_data = self[icon_id]

		if not icon_data then
			return ...
		end

		return icon_data.texture, icon_data.texture_rect
	end
end