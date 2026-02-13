if type(ChatManager.feed_system_message) ~= "function" then
	function ChatManager:feed_system_message(channel_id, message)
		if not Global.game_settings.single_player then
			self:_receive_message(channel_id, "SYSTEM", message, Color(255, 255, 212, 0) / 255)
		end
	end
end