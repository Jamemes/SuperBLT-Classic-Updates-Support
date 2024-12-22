if not tweak_data.hud_icons.csb_pagers then
	tweak_data.hud_icons.csb_pagers = {
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		texture_rect = {
			64 * 6,
			64 * 2,
			64,
			64
		}
	}
end

if not tweak_data.hud_icons.csb_locks then
	tweak_data.hud_icons.csb_locks = {
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		texture_rect = {
			64,
			64 * 4,
			64,
			64
		}
	}
end

if not tweak_data.hud_icons.csb_stamina then
	tweak_data.hud_icons.csb_stamina = {
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		texture_rect = {
			0,
			64 * 7,
			64,
			64
		}
	}
end

if not tweak_data.hud_icons.csb_throwables then
	tweak_data.hud_icons.csb_throwables = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			238,
			189.6,
			36,
			36
		}
	}
end

if not tweak_data.music.track_menu_list then
	tweak_data.music.track_list = {
		{ track = "track_01" },
		{ track = "track_02" },
		{ track = "track_03" },
		{ track = "track_04" },
		{ track = "track_05" },
		{ track = "track_06" },
		{ track = "track_07" },
		{ track = "track_08" },
		{ track = "track_09", lock = "armored" },
		{ track = "track_10" },
		{ track = "track_11", lock = "infamy" },
		{ track = "track_12", lock = "deathwish" },
		{ track = "track_13" },
		{ track = "track_14", lock = "bigbank" },
		{ track = "track_15" },
		{ track = "track_16" },
		{ track = "track_17", lock = "assault" },
		{ track = "track_18", lock = "miami" },
		{ track = "track_19", lock = "miami" },
		{ track = "track_20" },
		{ track = "track_21" },
		{ track = "track_22" },
		{ track = "track_23" },
		{ track = "track_24", lock = "diamond" },
		{ track = "track_25", lock = "thebomb" },
		{ track = "track_26" },
		{ track = "track_27" },
		{ track = "track_28" },
		{ track = "track_29", lock = "kenaz" },
		{ track = "track_30" },
		{ track = "track_31" },
		{ track = "track_35" },
		{ track = "track_36" },
		{ track = "track_37", hide_unavailable = true, lock = "berry" },
		{ track = "track_38", hide_unavailable = true, lock = "berry" },
		{ track = "track_39" },
		{ track = "track_40", lock = "peta" },
		{ track = "track_41", lock = "peta" },
		{ track = "track_42", lock = "pal" },
		{ track = "track_43", lock = "pal" },
		{ track = "track_44", hide_unavailable = true, lock = "mad" },
		{ track = "track_45", lock = "born" },
		{ track = "track_46", lock = "born" },
		{ track = "track_47_gen" },
		{ track = "track_48" },
		{ track = "track_49" },
		{ track = "track_50", hide_unavailable = true, lock = "friend" },
		{ track = "track_51", hide_unavailable = true, lock = "spa" },
		{ track = "track_52" },
		{ track = "track_53" },
		{ track = "track_54" },
		{ track = "track_55" },
		{ track = "track_56" },
		{ track = "track_57", hide_unavailable = true, lock = "rvd" },
		{ track = "track_58", hide_unavailable = true, lock = "rvd" },
		{ track = "track_59" },
		{ track = "track_60" },
		{ track = "track_61" },
		{ track = "track_62_lcv" },
		{ track = "track_63" },
		{ track = "track_64_lcv" },
		{ track = "track_32_lcv" },
		{ track = "track_33_lcv" },
		{ track = "track_34_lcv" },
		{ track = "track_65" },
		{ track = "track_66" },
		{ track = "track_67" },
		{ track = "track_68" },
		{ track = "track_69" },
		{ track = "track_70" },
		{ track = "track_71" },
		{ track = "track_72" },
		{ track = "track_73" },
		{ track = "track_74" },
		{ track = "track_75" },
		{ track = "track_76" },
		{ track = "track_77" },
		{ track = "track_78" },
		{ track = "track_79" },
		{ track = "track_80" },
		{ track = "track_pth_01", lock = "payday" },
		{ track = "track_pth_02", lock = "payday" },
		{ track = "track_pth_03", lock = "payday" },
		{ track = "track_pth_04", lock = "payday" },
		{ track = "track_pth_05", lock = "payday" },
		{ track = "track_pth_06", lock = "payday" },
		{ track = "track_pth_07", lock = "payday" },
		{ track = "track_pth_08", lock = "payday" },
		{ track = "track_pth_09", lock = "payday" }
	}
end

if not tweak_data.music.track_menu_list then
	tweak_data.music.track_menu_list = {
		{ track = "menu_music" },
		{ track = "loadout_music" },
		{ track = "music_loot_drop" },
		{ track = "resultscreen_win" },
		{ track = "resultscreen_lose" },
		{ track = "preplanning_music" },
		{ track = "preplanning_music_old" },
		{ track = "lets_go_shopping_menu" },
		{ track = "this_is_our_time" },
		{ track = "criminals_ambition" },
		{ track = "criminals_ambition_instrumental", lock = "soundtrack" },
		{ track = "release_trailer_track", lock = "soundtrack" },
		{ track = "ode_all_avidita", lock = "soundtrack" },
		{ track = "ode_all_avidita_instrumental", lock = "soundtrack" },
		{ track = "drifting", lock = "soundtrack" },
		{ track = "im_a_wild_one", lock = "soundtrack" },
		{ track = "the_flames_of_love" },
		{ track = "alesso_payday", lock = "alesso" },
		{ track = "pb_do_you_wanna", hide_unavailable = true, lock = "locked" },
		{ track = "pb_i_need_your_love", hide_unavailable = true, lock = "locked" },
		{ track = "pb_still_breathing", hide_unavailable = true, lock = "locked" },
		{ track = "pb_take_me_down", hide_unavailable = true, lock = "locked" },
		{ track = "biting_elbows_bad_motherfucker", hide_unavailable = true, lock = "locked" },
		{ track = "biting_elbows_for_the_kill", hide_unavailable = true, lock = "locked" },
		{ track = "half_passed_wicked", lock = "born_wild" },
		{ track = "bsides_04_double_lmgs", lock = "bsides" },
		{ track = "bsides_11_meat_and_machine_guns", lock = "bsides" },
		{ track = "bsides_05_rule_britannia", lock = "bsides" },
		{ track = "bsides_07_an_unexpected_call", lock = "bsides" },
		{ track = "bsides_13_infamy_2_0", lock = "bsides" },
		{ track = "bsides_12_the_enforcer", lock = "bsides" },
		{ track = "bsides_03_showdown", lock = "bsides" },
		{ track = "bsides_15_duel", lock = "bsides" },
		{ track = "bsides_02_swat_attack", lock = "bsides" },
		{ track = "bsides_08_this_is_goodbye", lock = "bsides" },
		{ track = "bsides_10_zagrebacka", lock = "bsides" },
		{ track = "bsides_16_pilgrim", lock = "bsides" },
		{ track = "bsides_14_collide", lock = "bsides" },
		{ track = "bsides_01_enter_the_hallway", lock = "bsides" },
		{ track = "bsides_06_hur_jag_trivs", lock = "bsides" },
		{ track = "pth_i_will_give_you_my_all", lock = "payday" },
		{ track = "pth_breaking_news", lock = "payday" },
		{ track = "pth_breaking_news_instrumental", lock = "payday" },
		{ track = "pth_criminal_intent", lock = "payday" },
		{ track = "pth_busted", lock = "payday" },
		{ track = "pth_busted_instrumental", lock = "payday" },
		{ track = "pth_see_you_at_the_safe_house", lock = "payday" },
		{ track = "pth_preparations", lock = "payday" },
		{ track = "xmas13_a_merry_payday_christmas", lock = "xmas" },
		{ track = "xmas13_a_heist_not_attempted_before", lock = "xmas" },
		{ track = "xmas13_if_it_has_to_be_christmas", lock = "xmas" },
		{ track = "xmas13_ive_been_a_bad_boy", lock = "xmas" },
		{ track = "xmas13_christmas_in_prison", lock = "xmas" },
		{ track = "xmas13_deck_the_safe_house", lock = "xmas" },
		{ track = "xmas13_if_it_has_to_be_christmas_american_version", lock = "xmas" },
		{ track = "xmas13_a_merry_payday_christmas_instrumental", lock = "xmas" },
		{ track = "xmas13_a_heist_not_attempted_before_instrumental", lock = "xmas" },
		{ track = "xmas13_if_it_has_to_be_christmas_instrumental", lock = "xmas" },
		{ track = "xmas13_ive_been_a_bad_boy_instrumental", lock = "xmas" },
		{ track = "xmas13_christmas_in_prison_instrumental", lock = "xmas" },
		{ track = "xmas13_deck_the_safe_house_instrumental", lock = "xmas" },
		{ track = "its_payday" },
		{ track = "music_tag" },
		{ track = "ojos_de_diamante" },
		{ track = "ojos_de_esmeralda" },
		{ track = "today_is_payday_too" },
		{ track = "jokes_on_them", lock = "tma1" },
		{ track = "ojos_de_diamante_new", lock = "tma1" },
		{ track = "ojos_de_esmeralda_new", lock = "tma1" },
		{ track = "silk_road", lock = "tma1" },
		{ track = "its_clown_time", lock = "tma1" }
	}
end