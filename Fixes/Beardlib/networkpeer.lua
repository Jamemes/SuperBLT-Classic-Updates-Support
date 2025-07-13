if type(NetworkPeer.melee_id) ~= "function" then
	function NetworkPeer:melee_id()
		local outfit_string = self:profile("outfit_string")
		local data = string.split(outfit_string, " ")

		return data[managers.blackmarket:outfit_string_index("melee_weapon")]
	end
end