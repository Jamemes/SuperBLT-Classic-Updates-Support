local F = table.remove(RequiredScript:split("/"))
if F == "menumanager" and type(MenuPrePlanningInitiator) ~= "nil" and type(MenuCallbackHandler.open_preplanning_rebuy) ~= "function" then
	local data = MenuPrePlanningInitiator.create_info_items
	function MenuPrePlanningInitiator:create_info_items(node, params, selected_item)
		local items = data(self, node, params, selected_item)

		if managers.preplanning:get_can_rebuy_assets() then
			params.name = "preplanning_rebuy"
			params.callback = "open_preplanning_rebuy"
			params.text_id = managers.localization:text("menu_item_preplanning_rebuy")
			params.tooltip = {
				texture = tweak_data.preplanning.gui.custom_icons_path,
				texture_rect = tweak_data.preplanning:get_custom_texture_rect(45),
				name = params.text_id,
				desc = managers.localization:text("menu_item_preplanning_rebuy_desc")
			}

			self:create_item(node, params)
		end
		
		return items
	end

	function MenuCallbackHandler:open_preplanning_rebuy(item)
		managers.preplanning:open_rebuy_menu()
	end

	Hooks:PostHook(MenuCallbackHandler, "_dialog_end_game_yes", "MenuCallbackHandler._dialog_end_game_yes.reset_rebuy_assets", function(self)
		managers.preplanning:reset_rebuy_assets()
	end)

	Hooks:PostHook(MenuCallbackHandler, "load_start_menu_lobby", "MenuCallbackHandler.load_start_menu_lobby.reset_rebuy_assets", function(self)
		managers.preplanning:reset_rebuy_assets()
	end)

	function MenuManager:show_confirm_preplanning_rebuy(params)
		local dialog_data = {
			title = "Rebuy Assets",
			text = "",
			text_formating_color_table = {},
			use_text_formating = true,
			w = 600
		}
		local red = tweak_data.screen_colors.important_1
		local grey = tweak_data.screen_color_grey
		local total_money_cost = 0
		local total_favor_cost = 0

		for _, plan in pairs(params.votes) do
			local category_text = utf8.to_upper(managers.preplanning:get_category_name_by_type(plan.type))
			local location_text = managers.preplanning:get_element_name_by_type_index(plan.type, plan.index)
			local name_text = managers.preplanning:get_type_name(plan.type)
			local cost_text = managers.preplanning:get_type_cost_text(plan.type)
			dialog_data.text = dialog_data.text .. category_text .. "\n"
			dialog_data.text = dialog_data.text .. "  -" .. name_text

			if not string.match(location_text, "ERROR") then
				dialog_data.text = dialog_data.text .. " - " .. location_text
			end

			dialog_data.text = dialog_data.text .. " (" .. cost_text .. ") \n \n"
			total_money_cost = total_money_cost + managers.preplanning:_get_type_cost(plan.type)
			total_favor_cost = total_favor_cost + managers.preplanning:get_type_budget_cost(plan.type)
		end

		local category_list = {}

		for _, asset in ipairs(params.rebuy_assets) do
			local cat_name = utf8.to_upper(managers.preplanning:get_category_name_by_type(asset.type))
			local create_new_category = true

			for _, category in ipairs(category_list) do
				if cat_name == category.category then
					table.insert(category.assets, {
						type = asset.type,
						id = asset.id,
						index = asset.index
					})

					create_new_category = false
				end
			end

			if create_new_category then
				table.insert(category_list, {
					category = cat_name,
					assets = {
						{
							type = asset.type,
							id = asset.id,
							index = asset.index
						}
					}
				})
			end
		end

		for _, category in ipairs(category_list) do
			dialog_data.text = dialog_data.text .. category.category .. " \n"

			for _, asset in ipairs(category.assets) do
				local money_cost = managers.preplanning:_get_type_cost(asset.type)
				local favor_cost = managers.preplanning:get_type_budget_cost(asset.type)
				local td = managers.preplanning:get_tweak_data_by_type(asset.type)
				local name_text = managers.preplanning:get_type_name(asset.type)
				local cost_text = managers.preplanning:get_type_cost_text(asset.type)
				local location_text = managers.preplanning:get_element_name_by_type_index(asset.type, asset.index)
				local can_unlock = true

				if td.dlc_lock then
					can_unlock = can_unlock and managers.dlc:is_dlc_unlocked(td.dlc_lock)
				end

				if td.upgrade_lock then
					can_unlock = can_unlock and managers.player:has_category_upgrade(td.upgrade_lock.category, td.upgrade_lock.upgrade)
				end

				if not can_unlock then
					table.insert(dialog_data.text_formating_color_table, grey)

					dialog_data.text = dialog_data.text .. "##"
				else
					total_money_cost = total_money_cost + money_cost
					total_favor_cost = total_favor_cost + favor_cost
				end

				dialog_data.text = dialog_data.text .. "   -" .. name_text

				if not string.match("ERROR", location_text) then
					dialog_data.text = dialog_data.text .. " - " .. location_text
				end

				dialog_data.text = dialog_data.text .. " (" .. cost_text .. ")"

				if td.upgrade_lock and not can_unlock then
					dialog_data.text = dialog_data.text .. "##"

					table.insert(dialog_data.text_formating_color_table, red)

					dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_skill")
				elseif td.dlc_lock and not can_unlock then
					dialog_data.text = dialog_data.text .. "##"

					table.insert(dialog_data.text_formating_color_table, red)

					dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_dlc", {
						dlc = managers.localization:text(self:get_dlc_by_id(td.dlc_lock).name_id)
					})
				end

				dialog_data.text = dialog_data.text .. "\n"
			end
		end

		dialog_data.text = dialog_data.text .. "\n"

		if total_money_cost < managers.money:total() then
			dialog_data.text = dialog_data.text .. managers.localization:text("dialog_preplanning_rebuy_assets", {
				price = managers.experience:cash_string(total_money_cost),
				favor = total_favor_cost
			})
			local yes_button = {
				text = managers.localization:text("dialog_yes"),
				callback_func = params.yes_func
			}
			local no_button = {
				cancel_button = true,
				text = managers.localization:text("dialog_no")
			}
			dialog_data.focus_button = 2
			dialog_data.button_list = {
				yes_button,
				no_button
			}
		else
			dialog_data.text = dialog_data.text .. "##" .. managers.localization:text("bm_menu_not_enough_cash") .. "##"

			table.insert(dialog_data.text_formating_color_table, red)

			local ok_button = {
				text = managers.localization:text("dialog_ok"),
				cancel_button = true
			}
			dialog_data.focus_button = 1
			dialog_data.button_list = {
				ok_button
			}
		end

		managers.system_menu:show(dialog_data)
	end

	function MenuManager:get_dlc_by_id(dlc_id)
		for _, dlc in ipairs(tweak_data.gui.content_updates.item_list) do
			if dlc.id == dlc_id then
				return dlc
			end
		end

		return "Failed to get DLC"
	end
elseif F == "preplanningmapgui" and type(PrePlanningMapGui) ~= "nil" then
	Hooks:PostHook(PrePlanningMapGui, "set_active_node", "PrePlanningMapGui.set_active_node.on_preplanning_open", function(self, node)
		if self._enabled then
			managers.preplanning:on_preplanning_open_old()
		end
	end)
elseif F == "preplanningmanager" and type(PrePlanningManager) ~= "nil" and type(PrePlanningManager.open_rebuy_menu) ~= "function" then
	local function debug_assert(chk, ...)
		if not chk then
			local s = ""

			for i, text in ipairs({
				...
			}) do
				s = s .. "  " .. text
			end

			assert(chk, s)
		end
	end

	Hooks:PostHook(PrePlanningManager, "init", "PrePlanningManager.init.rebuy_assets", function(self, node)
		if not Global.preplanning_manager then
			Global.preplanning_manager = {
				rebuy_assets = {}
			}
		end

		self._rebuy_assets = Global.preplanning_manager.rebuy_assets
		self._rebuy_assets.reminder_active = true
	end)

	function PrePlanningManager:on_preplanning_open_old()
		if self:get_can_rebuy_assets() and self._rebuy_assets.reminder_active then
			self._rebuy_assets.reminder_active = false

			self:open_rebuy_menu()
		end
	end

	function PrePlanningManager:open_rebuy_menu()
		if not self:get_can_rebuy_assets() then
			return
		end

		local params = {
			yes_func = callback(self, self, "reserve_rebuy_mission_elements"),
			rebuy_assets = self._rebuy_assets.assets,
			votes = self._rebuy_assets.votes
		}

		managers.menu:show_confirm_preplanning_rebuy(params)
	end

	function PrePlanningManager:get_can_rebuy_assets()
		return self._rebuy_assets and self._rebuy_assets.assets and #self._rebuy_assets.assets ~= 0 and self._rebuy_assets.level_id == managers.job:current_level_id()
	end

	function PrePlanningManager:reset_rebuy_assets()
		Global.preplanning_manager.rebuy_assets = {}
	end

	function PrePlanningManager:mass_vote_on_plan(type, id)
		local peer_id = managers.network:session():local_peer():id()

		if Network:is_server() then
			self:server_mass_vote_on_plan(type, id)
		else
			managers.network:session():send_to_host("reserve_preplanning", type, id, 2)
		end
	end

	function PrePlanningManager:server_mass_vote_on_plan(type, id)
		self:vote_on_plan(type, id)
		for _, peer in pairs(managers.network:session():all_peers()) do
			self:_server_vote_on_plan(type, id, peer:id())
		end
	end

	function PrePlanningManager:reserve_rebuy_mission_elements()
		if not self._rebuy_assets then
			return
		end

		for _, asset in ipairs(self._rebuy_assets.assets) do
			local td = self:get_tweak_data_by_type(asset.type)
			local can_unlock = self:can_reserve_mission_element(asset.type)

			if can_unlock then
				self:reserve_mission_element(asset.type, asset.id)
			end
		end

		for _, plan in ipairs(self._rebuy_assets.votes) do
			if self:can_vote_on_plan(plan.type, managers.network:session():local_peer():id()) then
				self:mass_vote_on_plan(plan.type, plan.id)
			end
		end
	end

	function PrePlanningManager:on_execute_preplanning()
		if self:has_current_level_preplanning() then
			managers.money:on_buy_preplanning_types()
			managers.money:on_buy_preplanning_votes()

			local current_budget, total_budget = self:get_current_budget()

			if current_budget == total_budget and managers.job:current_level_id() == "big" then
				managers.achievment:award("bigbank_8")
			end

			local local_peer_id = managers.network:session():local_peer():id()
			local award_achievement, progress_stat, type_data = nil

			for id, data in pairs(self._reserved_mission_elements) do
				if data.peer_id == local_peer_id then
					type_data = tweak_data.preplanning.types[data.pack[1]]

					if type_data then
						award_achievement = type_data.award_achievement

						if award_achievement then
							managers.achievment:award(award_achievement)
						end

						progress_stat = type_data.progress_stat

						if progress_stat then
							managers.achievment:award_progress(progress_stat)
						end
					end
				end
			end

			if self._reserved_mission_elements then
				Global.preplanning_manager.rebuy_assets.assets = {}

				for id, asset in pairs(self._reserved_mission_elements) do
					local asset_type = asset.pack[1]
					local index = asset.pack[2]

					table.insert(Global.preplanning_manager.rebuy_assets.assets, {
						id = id,
						type = asset_type,
						index = index
					})
				end
			end

			local winners = self:get_current_majority_votes()

			if winners then
				Global.preplanning_manager.rebuy_assets.votes = {}

				for _, data in pairs(winners) do
					local type, index = unpack(data)

					table.insert(Global.preplanning_manager.rebuy_assets.votes, {
						index = index,
						id = self:get_mission_element_id(type, index),
						type = type
					})
				end
			end

			Global.preplanning_manager.rebuy_assets.level_id = managers.job:current_level_id()
		end

		self._reserved_mission_elements = {}
		self._players_votes = {}
		self._executed_reserved_mission_elements = nil
	end

	function PrePlanningManager:get_element_name_by_type_index(type, index)
		return managers.localization:text("menu_" .. self._mission_elements_by_type[type][index]:editor_name())
	end

	function PrePlanningManager:get_type_cost_text(type)
		local type_data = tweak_data:get_raw_value("preplanning", "types", type)

		debug_assert(type_data, "[PrePlanningManager:get_type_desc] Type do not exist in tweak data!", "type", type)

		local text_string = ""
		local cost_money = managers.money:get_preplanning_type_cost(type)
		local cost_budget = self:get_type_budget_cost(type)

		if cost_money == 0 and cost_budget == 0 then
			text_string = text_string .. managers.localization:text("menu_pp_free_of_charge")
		else
			text_string = text_string .. managers.localization:text("menu_pp_tooltip_costs", {
				money = managers.experience:cash_string(cost_money),
				budget = cost_budget
			})
		end

		return text_string
	end

	function PrePlanningManager:get_tweak_data_by_type(type)
		return tweak_data:get_raw_value("preplanning", "types", type)
	end
end