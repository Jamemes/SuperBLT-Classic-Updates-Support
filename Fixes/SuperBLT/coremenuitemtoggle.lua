core:module("CoreMenuItemToggle")
core:import("CoreMenuItem")
core:import("CoreMenuItemOption")

local data = ItemToggle.reload
function ItemToggle:reload(row_item, node)
	if not row_item then
		return
	end
	
	return data(self, row_item, node)
end