if type(BaseNetworkSession.peer_by_unit) ~= "function" then
	function BaseNetworkSession:peer_by_unit(unit)
		local wanted_key = unit:key()

		for _, peer in pairs(self:all_peers()) do
			local test_unit = peer:unit()

			if alive(test_unit) and test_unit:key() == wanted_key then
				return peer
			end
		end
	end
end

if type(BaseNetworkSession.all_peers) ~= "function" then
	function BaseNetworkSession:all_peers()
		local local_peer = self:local_peer()
		local all_peers = clone(self:peers())
		all_peers[local_peer:id()] = local_peer

		return all_peers or {}
	end
end