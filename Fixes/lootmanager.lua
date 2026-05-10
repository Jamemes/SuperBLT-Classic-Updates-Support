Hooks:PostHook(LootManager, "_setup", "SBLT_CUS.LootManager._setup.apply_preserved_loot", function()
	if Global.save_slots and Global.save_slots[Global.save_slots.current_slot] and Global.save_slots[Global.save_slots.current_slot].job_preserved and managers.savefile._reserve_load then
		Global.loot_manager = Global.save_slots[Global.save_slots.current_slot].job_preserved.loot_manager
		managers.savefile._reserve_load = nil
	end
end)