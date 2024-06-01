SavefileManager.SETTING_SLOT = 2
SavefileManager.PROGRESS_SLOT = 37
SavefileManager.BACKUP_SLOT = 37

function SavefileManager:update(t, dt)
	self:update_gui_visibility()

	if self._loading_sequence and not self:_is_loading() then
		self:_on_load_sequence_complete()
	end
end