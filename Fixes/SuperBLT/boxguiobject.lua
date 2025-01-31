function BoxGuiObject:set_aligns(halign, valign)
	for i, d in pairs(self._panel:children()) do
		d:set_valign(valign)
		d:set_halign(halign)
	end
end