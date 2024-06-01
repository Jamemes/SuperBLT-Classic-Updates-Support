Hooks:Add("LocalizationManagerPostInit", "CrimeNET_Enhanced_loc", function(...)
	LocalizationManager:add_localized_strings({
		menu_button_throwable = "Use Throwable",
		menu_filter_search = "Search",
		menu_button_hide = "Hide",
		menu_button_show = "Show",
	})

	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			menu_button_throwable = "Использовать метательное",
			menu_filter_search = "Поиск",
			menu_button_hide = "Скрыть",
			menu_button_show = "Показать",
		})
	end
end)

if not call_on_next_update then
	function call_on_next_update(func, optional_key)
		func()
	end
end

local data = BLTKeybind.Key
function BLTKeybind:Key()
	return data(self) or ""
end

function file.FileExists(path)
	return os.rename(path, path)
end

function file.DirectoryExists(path)
	return os.rename(path, path)
end

function file.MoveDirectory(prev, path)
	return os.rename(prev, path)
end

local data = unzip
unzip = function(path1, path2)
	os.execute("mkdir " .. path2)
	data(path1, path2)
end

local data = dohttpreq
dohttpreq = function(path, func)
	override = function(...)
		local params = {...}
		if not params[3] then
			params[3] = {querySucceeded = true}
		end
		
		return func(params[1], params[2], params[3])
	end
	
	return data(path, override)
end

function table.map_append(t, ...)
	for _, list_table in ipairs({
		...
	}) do
		for key, value in pairs(list_table) do
			t[key] = value
		end
	end

	return t
end

if not DB:has("texture", "guis/textures/pd2/ad_spot") then
	Hooks:PostHook(BLTNotificationsGui, "_update_bars", "ad_spot_painter", function(self)
		for i = 1, self._notifications_count do
			self._buttons_panel:child(tostring(i)):set_alpha(0)
		end
	end)
end

function MenuSceneManager:input_focus()
	return self._character_grabbed or self._item_grabbed and true or false
end

Hooks:PostHook(MenuSceneManager, "_set_up_templates", "add_crew_management_template", function(self)
	if not self._scene_templates.crew_management then
		MenuHelper:AddComponent("crew_management", BLTNotificationsGui)
		local ref = self._bg_unit:get_object(Idstring("a_camera_reference"))
		local c_ref = self._bg_unit:get_object(Idstring("a_reference"))
		local target_pos = Vector3(0, 0, ref:position().z)
		local offset = Vector3(ref:position().x, ref:position().y, 0)
		self._scene_templates.crew_management = {
			use_character_grab = false,
			camera_pos = offset:rotate_with(Rotation(90)),
			target_pos = target_pos,
			character_pos = c_ref:position() + Vector3(0, 500, 0),
			character_visible = false,
			lobby_characters_visible = false,
			henchmen_characters_visible = true,
			fov = 40,
			lights = {
				self:_create_light({
					far_range = 300,
					color = Vector3(0.86, 0.57, 0.31) * 3,
					position = Vector3(56, 100, -10)
				}),
				self:_create_light({
					far_range = 3000,
					specular_multiplier = 6,
					color = Vector3(1, 2.5, 4.5) * 3,
					position = Vector3(-1000, -300, 800)
				}),
				self:_create_light({
					far_range = 800,
					specular_multiplier = 0,
					color = Vector3(1, 1, 1) * 0.35,
					position = Vector3(300, 100, 0)
				})
			}
		}
	end
end)

function ExperienceManager:cash_string(cash, cash_sign)
	local sign = ""

	if cash < 0 then
		sign = "-"
	end

	local total = tostring(math.round(math.abs(cash)))
	local reverse = string.reverse(total)
	local s = ""

	for i = 1, string.len(reverse) do
		s = s .. string.sub(reverse, i, i) .. (math.mod(i, 3) == 0 and i ~= string.len(reverse) and self._cash_tousand_separator or "")
	end

	local final_cash_sign = type(cash_sign) == "string" and (cash_sign or self._cash_sign) or self._cash_sign

	return sign .. final_cash_sign .. string.reverse(s)
end