
local F = table.remove(RequiredScript:split("/"))
if F == "jobmanager" then
	Hooks:PostHook(JobManager, "next_stage", "SBLT_CUS.JobManager.next_stage.job_preserve", function(self)
		if _G.LuaNetworking:IsHost() and not managers.job:is_job_finished() then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = {
				job_manager = Global.job_manager,
				game_settings = Global.game_settings,
				loot_manager = Global.loot_manager,
				asset_manager = Global.asset_manager,
				mission_manager = Global.mission_manager,
			}

			managers.savefile:_save()
		end
	end)
elseif F == "lootmanager" then
	Hooks:PostHook(LootManager, "_setup", "SBLT_CUS.LootManager._setup.apply_preserved_loot", function()
		if Global.save_slots and Global.save_slots[Global.save_slots.current_slot] and Global.save_slots[Global.save_slots.current_slot].job_preserved and managers.savefile.job_preserved then
			Global.loot_manager = Global.save_slots[Global.save_slots.current_slot].job_preserved.loot_manager
		end
	end)
elseif F == "menumanager" then
	Hooks:PostHook(MenuManager, "on_enter_lobby", "SBLT_CUS.MenuManager.on_enter_lobby.load_preserved_heist", function()
		if Global.save_slots[Global.save_slots.current_slot].job_preserved and managers.savefile.job_preserved then
			MenuCallbackHandler:lobby_start_the_game()
		elseif Global.save_slots[Global.save_slots.current_slot].job_preserved then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
			managers.savefile:_save()
		end
	end)

	Hooks:PostHook(MenuCallbackHandler, "_dialog_end_game_yes", "SBLT_CUS.MenuCallbackHandler._dialog_end_game_yes.remove_preserved_heist", function()
		if Global.save_slots[Global.save_slots.current_slot].job_preserved then
			Global.save_slots[Global.save_slots.current_slot].job_preserved = nil
			managers.savefile:_save()
		end
	end)

	local data = MenuManager.show_question_start_tutorial
	function MenuManager:show_question_start_tutorial(params)
		if not Global.save_slots[Global.save_slots.current_slot].job_preserved then
			data(self, params)
		end
	end
end