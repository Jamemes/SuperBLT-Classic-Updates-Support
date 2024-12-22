local data = ExperienceManager.cash_string
function ExperienceManager:cash_string(cash, cash_sign)
	local cash_string = data(self, cash)
	
	if cash_sign then
		cash_string = cash_sign .. cash_string:sub(2, #cash_string)
	end

	return cash_string
end