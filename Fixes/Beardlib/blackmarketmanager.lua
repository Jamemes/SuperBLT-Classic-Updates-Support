if type(BlackMarketManager.equipped_armor_skin) ~= "function" then
	function BlackMarketManager:equipped_armor_skin()
		return "none"
	end
end

if type(BlackMarketManager.equipped_melee_weapon) ~= "function" then
	function BlackMarketManager:equipped_melee_weapon()
		return "weapon"
	end
end

if type(BlackMarketManager.equipped_player_style) ~= "function" then
	function BlackMarketManager:equipped_player_style()
		return "none"
	end
end

if type(BlackMarketManager.equipped_suit_variation) ~= "function" then
	function BlackMarketManager:equipped_suit_variation()
		return "default"
	end
end

if type(BlackMarketManager.equipped_glove_id) ~= "function" then
	function BlackMarketManager:equipped_glove_id()
		return "default"
	end
end

if type(BlackMarketManager.outfit_string_from_list) ~= "function" then
	function BlackMarketManager:outfit_string_from_list(outfit)
		PrintTable(outfit)
		local s = ""
		s = s .. outfit.mask.mask_id
		s = s .. " " .. outfit.mask.blueprint.color.id
		s = s .. " " .. outfit.mask.blueprint.pattern.id
		s = s .. " " .. outfit.mask.blueprint.material.id
		s = s .. " " .. outfit.armor
		s = s .. " " .. outfit.character
		local primary_string = managers.weapon_factory:blueprint_to_string(outfit.primary.factory_id, outfit.primary.blueprint)
		primary_string = string.gsub(primary_string, " ", "_")
		s = s .. " " .. outfit.primary.factory_id .. " " .. primary_string
		local secondary_string = managers.weapon_factory:blueprint_to_string(outfit.secondary.factory_id, outfit.secondary.blueprint)
		secondary_string = string.gsub(secondary_string, " ", "_")
		s = s .. " " .. outfit.secondary.factory_id .. " " .. secondary_string
		local equipped_deployable = outfit.deployable
		if equipped_deployable then
			s = s .. " " .. outfit.deployable
			s = s .. " " .. tostring(outfit.deployable_amount)
		else
			s = s .. " " .. "nil" .. " " .. "0"
		end
		s = s .. " " .. tostring(outfit.concealment_modifier)
		s = s .. " " .. tostring(outfit.melee_weapon)
		s = s .. " " .. tostring(outfit.grenade)
		return s
	end
end

if type(BlackMarketManager.get_sorted_deployables) ~= "function" then
	function BlackMarketManager:get_sorted_deployables(hide_locked)
		local sort_data = {}

		for id, d in pairs(tweak_data.blackmarket.deployables) do
			if not hide_locked or table.contains(managers.player:availible_equipment(1), id) then
				table.insert(sort_data, {
					id,
					d
				})
			end
		end

		table.sort(sort_data, function (x, y)
			return x[1] < y[1]
		end)

		return sort_data
	end
end