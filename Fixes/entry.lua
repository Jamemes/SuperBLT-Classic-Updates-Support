if not DB:has("texture", "guis/textures/pd2/ad_spot") then
	Hooks:PostHook(BLTNotificationsGui, "_update_bars", "ad_spot_painter", function(self)
		for i = 1, self._notifications_count do
			self._buttons_panel:child(tostring(i)):set_alpha(0)
		end
	end)
end

local data = BLTKeybind.Key
function BLTKeybind:Key()
	return data(self) or ""
end