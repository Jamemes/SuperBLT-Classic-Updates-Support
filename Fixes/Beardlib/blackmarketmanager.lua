log(type(BlackMarketManager.equipped_armor_skin))
if type(BlackMarketManager.equipped_armor_skin) ~= "function" then
	function BlackMarketManager:equipped_armor_skin()
		return "none"
	end
	log(type(BlackMarketManager.equipped_armor_skin))
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
		return self:outfit_string()
	end
end