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

function MenuSceneManager:input_focus()
	return self._character_grabbed or self._item_grabbed and true or false
end
