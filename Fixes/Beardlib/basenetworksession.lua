if type(BaseNetworkSession.peer_by_unit) ~= "function" then
	function BaseNetworkSession:peer_by_unit(unit)
		local wanted_key = unit:key()

		for _, peer in pairs(self._peers_all or {}) do
			local test_unit = peer:unit()

			if alive(test_unit) and test_unit:key() == wanted_key then
				return peer
			end
		end
	end
end