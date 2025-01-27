-- if not BlackMarketTweakData.suit_default_gloves then
	-- BlackMarketTweakData.suit_default_gloves = {}
-- end

-- if not BlackMarketTweakData.glove_adapter then
	-- BlackMarketTweakData.glove_adapter = {
		-- player_style_exclude_list = {}
	-- }
-- end
-- function BlackMarketTweakData:get_glove_value(glove_id, character_name, key, player_style, material_variation)
	-- if key == nil then
		-- return
	-- end

	-- glove_id = glove_id or "default"

	-- if glove_id == "default" then
		-- glove_id = self.suit_default_gloves[player_style]

		-- if glove_id == false then
			-- return false
		-- end
	-- end

	-- local data = self.gloves[glove_id or "default"]

	-- if data == nil then
		-- return nil
	-- end

	-- character_name = CriminalsManager.convert_old_to_new_character_workname(character_name)
	-- local character_value = data.characters and data.characters[character_name] and data.characters[character_name][key]

	-- if character_value ~= nil then
		-- return character_value
	-- end

	-- local tweak_value = data and data[key]

	-- return tweak_value
-- end

-- function BlackMarketTweakData:build_glove_list(tweak_data)
	-- local x_td, y_td, x_gv, y_gv, x_sn, y_sn = nil

	-- local function sort_func(x, y)
		-- if x == "default" then
			-- return true
		-- end

		-- if y == "default" then
			-- return false
		-- end

		-- x_td = self.gloves[x]
		-- y_td = self.gloves[y]

		-- if x_td.unlocked ~= y_td.unlocked then
			-- return x_td.unlocked
		-- end

		-- x_gv = x_td.global_value or x_td.dlc or "normal"
		-- y_gv = y_td.global_value or y_td.dlc or "normal"
		-- x_sn = x_gv and tweak_data.lootdrop.global_values[x_gv].sort_number or 0
		-- y_sn = y_gv and tweak_data.lootdrop.global_values[y_gv].sort_number or 0
		-- x_sn = x_sn + (x_td.gv_sort_number or 0)
		-- y_sn = y_sn + (y_td.gv_sort_number or 0)

		-- if x_sn ~= y_sn then
			-- return x_sn < y_sn
		-- end

		-- x_sn = x_td.sort_number or 0
		-- y_sn = y_td.sort_number or 0

		-- if x_sn ~= y_sn then
			-- return x_sn < y_sn
		-- end

		-- return x < y
	-- end

	-- self.glove_list = table.map_keys(self.gloves, sort_func)
-- end