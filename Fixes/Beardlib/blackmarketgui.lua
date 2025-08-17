local item = BlackMarketGuiSlotItem.init
function BlackMarketGuiSlotItem:init(main_panel, data, ...)
	item(self, main_panel, data, ...)

	if data.bitmap_texture and not DB:has(Idstring("texture"), data.bitmap_texture) then
		local texture_loaded_clbk = callback(self, self, "texture_loaded_clbk")
		self._loading_texture = true
		if data.stream then
			self._requested_texture = data.bitmap_texture
			self._request_index = managers.menu_component:request_texture(self._requested_texture, callback(self, self, "texture_loaded_clbk"))
		else
			texture_loaded_clbk(data.bitmap_texture, Idstring(data.bitmap_texture))
		end
	end
end