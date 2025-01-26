local csb_size = 128
local atlas = DB:has(Idstring("texture"), Idstring("guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas"))
-- log(atlas)
local tbl = nil
if not tweak_data.hud_icons.csb_pagers then
	if atlas then
		tbl = {
			texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
			texture_rect = {
				csb_size * 6,
				csb_size * 1,
				csb_size,
				csb_size
			}
		}
	else
		tbl = {
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = {
				64 * 6,
				64 * 2,
				64,
				64
			}
		}
	end
	
	tweak_data.hud_icons.csb_pagers = tbl
end

if not tweak_data.hud_icons.csb_locks then
	if atlas then
		tbl = {
			texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
			texture_rect = {
				csb_size * 1,
				csb_size * 2,
				csb_size,
				csb_size
			}
		}
	else
		tbl = {
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = {
				64,
				64 * 4,
				64,
				64
			}
		}
	end
	
	tweak_data.hud_icons.csb_locks = tbl
end

if not tweak_data.hud_icons.csb_stamina then
	if atlas then
		tbl = {
			texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
			texture_rect = {
				csb_size * 1,
				csb_size * 0,
				csb_size,
				csb_size
			}
		}
	else
		tbl = {
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = {
				0,
				64 * 7,
				64,
				64
			}
		}
	end
	
	tweak_data.hud_icons.csb_stamina = tbl 
end

if not tweak_data.hud_icons.csb_throwables then
	if atlas then
		tbl = {
			texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
			texture_rect = {
				csb_size * 1,
				csb_size * 1,
				csb_size,
				csb_size
			}
		}
	else
		tbl = {
			texture = "guis/textures/hud_icons",
			texture_rect = {
				238,
				189.6,
				36,
				36
			}
		}
	end
	
	tweak_data.hud_icons.csb_throwables = tbl
end