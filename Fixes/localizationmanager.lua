local data = LocalizationManager.text
function LocalizationManager:text(string_id, macros)
	string_id = string_id or ""
	return data(self, string_id, macros)
end