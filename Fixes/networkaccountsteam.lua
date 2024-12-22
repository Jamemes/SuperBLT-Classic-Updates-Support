function NetworkAccountSTEAM:is_overlay_enabled()
	return MenuCallbackHandler:is_overlay_enabled()
end

function NetworkAccountSTEAM:overlay_activate(...)
	if self:is_overlay_enabled() then
		Steam:overlay_activate(...)
	else
		managers.menu:show_enable_steam_overlay()
	end
end