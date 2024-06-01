console.CreateConsole()

local SystemMenuManager = "mods/base/lua/SystemMenuManager.lua"
if os.rename(SystemMenuManager, SystemMenuManager) then
	log("SystemMenuManager.lua exist. Removing...")
	os.remove(SystemMenuManager)
end
