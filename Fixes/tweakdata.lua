tweak_data.screen_colors.dark_bg = Color(0.65, 0, 0, 0)
tweak_data.hud_icons.csb_pagers = {
	texture = "guis/textures/pd2/skilltree/icons_atlas",
	texture_rect = {
		64 * 6,
		64 * 2,
		64,
		64
	}
}

tweak_data.hud_icons.csb_locks = {
	texture = "guis/textures/pd2/skilltree/icons_atlas",
	texture_rect = {
		64,
		64 * 4,
		64,
		64
	}
}

tweak_data.hud_icons.csb_stamina = {
	texture = "guis/textures/pd2/skilltree/icons_atlas",
	texture_rect = {
		0,
		64 * 7,
		64,
		64
	}
}

tweak_data.hud_icons.csb_throwables = {
	texture = "guis/textures/pd2/hud_progress_32px",
	texture_rect = {
		0,
		0,
		32,
		32
	}
}

if not tweak_data.hud_icons.scrollbar_arrow then
	tweak_data.hud_icons.scrollbar_arrow = {
		texture = "guis/textures/menu_arrows",
		texture_rect = {
			0,
			0,
			24,
			24
		}
	}
end

if not tweak_data.BUNDLED_DLC_PACKAGES then
	tweak_data.BUNDLED_DLC_PACKAGES = {}
end