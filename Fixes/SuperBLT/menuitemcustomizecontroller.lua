function MenuItemCustomizeController:setup_gui(node, row_item)
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	row_item.controller_name = node:_text_item_part(row_item, row_item.gui_panel, node:_left_align())

	row_item.controller_name:set_align("right")

	row_item.controller_binding = node:_text_item_part(row_item, row_item.gui_panel, node:_left_align(), "left")

	row_item.controller_binding:set_align("left")
	row_item.controller_binding:set_text(string.upper(row_item.item:parameters().binding or ""))
	row_item.controller_binding:set_color(tweak_data.menu.default_changeable_text_color)
	self:_layout(node, row_item)

	return true
end

function MenuItemCustomizeController:reload(row_item, node)
	if self:parameters().axis then
		row_item.controller_binding:set_text(string.upper(self:parameters().binding or ""))
	else
		row_item.controller_binding:set_text(string.upper(self:parameters().binding or ""))
	end

	return true
end