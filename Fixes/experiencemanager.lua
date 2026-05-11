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

Hooks:PostHook(ExperienceManager, "give_experience", "SBLT_CUS.ExperienceManager.give_experience.save_progress_after_the experience", function()
	if game_state_machine:current_state_name() == "victoryscreen" then
		if managers.job:on_last_stage() then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
		else
			managers.savefile:_save("victoryscreen_reserve")
		end
	elseif game_state_machine:current_state_name() == "gameoverscreen" and managers.job:is_current_job_professional() then
		Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
	end
end)