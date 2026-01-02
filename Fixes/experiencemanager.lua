if type(ExperienceManager.experience_string) == "nil" then
	function ExperienceManager:experience_string(xp)
		local total = tostring(math.round(math.abs(xp)))
		local reverse = string.reverse(total)
		local s = ""

		for i = 1, string.len(reverse) do
			s = s .. string.sub(reverse, i, i) .. (math.mod(i, 3) == 0 and i ~= string.len(reverse) and self._cash_tousand_separator or "")
		end

		return string.reverse(s)
	end
end