if NewHeistsGui then
	return
end

NewHeistsGui = NewHeistsGui or class()
function NewHeistsGui:set_bar_width(w, random)
	w = w or 32
	self._bar_width = w

	self._bar:set_width(w)

	self._bar_x = not random and self._bar_x or math.random(1, 255)
	self._bar_y = not random and self._bar_y or math.random(0, math.round(self._bar:texture_height() / 2 - 1)) * 2
	local x = self._bar_x
	local y = self._bar_y
	local h = 6
	local mvector_tl = Vector3()
	local mvector_tr = Vector3()
	local mvector_bl = Vector3()
	local mvector_br = Vector3()

	mvector3.set_static(mvector_tl, x, y, 0)
	mvector3.set_static(mvector_tr, x + w, y, 0)
	mvector3.set_static(mvector_bl, x, y + h, 0)
	mvector3.set_static(mvector_br, x + w, y + h, 0)
	self._bar:set_texture_coordinates(mvector_tl, mvector_tr, mvector_bl, mvector_br)
end