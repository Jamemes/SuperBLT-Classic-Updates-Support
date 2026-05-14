local game_ver = SBLT_CUS:game_version()
local game_update = tweak_data.updates_table[game_ver] or ""
Hooks:Add("LocalizationManagerPostInit", "SBLT_CUS_loc", function(...)
	LocalizationManager:add_localized_strings({
		menu_button_throwable = "Use Throwable",
		menu_filter_search = "Search",
		menu_button_hide = "Hide",
		menu_button_show = "Show",
		sblt_cus_port_progress = "Port the Progress",
		sblt_cus_port_progress_help = string.format("%s  (Current Update: %s)", "Choose the slot from 0 to 99.", game_update),
		sblt_cus_try_again = "Try again",
		sblt_cus_slot_changed = "The slot has been changed",
		sblt_cus_choose_slot = "Choose the slot",
		sblt_cus_port_dialog = "Choose the file to port the progress - saveXXX.sav.",
		sblt_cus_game_version_changed = "Different game version",
		sblt_cus_confirm_changes = "Confirm the changes",
		sblt_cus_returned_title = "Returned",
		sblt_cus_returned_text = "The items has been returned to the inventory.",
		sblt_cus_stashed_title = "Stashed",
		sblt_cus_stashed_text = "This items is hidden because it is incompatible with this version of the game or modified with incompatible items and will be returned when you launch the version where this item will be available.",
		sblt_cus_slot_switched = "The slot has been switched.\n\nA slot has been found with a version that matches the current version of the game.",
		sblt_cus_slot_not_found = "There is no slot that matches the current version. You must select the slot manually.",
		sblt_cus_savefile_not_found = "Save file can't be loaded: %s.\n\nYou will be asked to choose the save file from which the data will be ported. This option will not affect your save files, it will only read one of them and transfer the data from there to the new system.\nAfter that, you can play any version of the game without harming your saved data.",
		sblt_cus_save_not_loaded = "Save file can't be loaded: %s.\n\nYou need to select the save file on which you last played in the old save system. ",
		sblt_cus_port_from_savefile = "Are you sure you want port the progress from the file %s?\n\nYour current progress will be gone.",
		sblt_cus_dialog_different_version = "Game version: %s\nSave version: %s\n\nThis slot was used on other version of the game. All unavailable items will be stashed until you will return on the version that matched this slot. Continue?",
	})

	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			menu_button_throwable = "Использовать метательное",
			menu_filter_search = "Поиск",
			menu_button_hide = "Скрыть",
			menu_button_show = "Показать",
			sblt_cus_port_progress = "Слот прогресса",
			sblt_cus_port_progress_help = string.format("%s  (Эта версия: %s)", "Выберите слот с 0 по 99.", game_update),
			sblt_cus_try_again = "Попробовать снова",
			sblt_cus_slot_changed = "Слот изменен",
			sblt_cus_choose_slot = "Выберите слот",
			sblt_cus_port_dialog = "Выберите файл для портирования прогресса - saveXXX.sav.",
			sblt_cus_game_version_changed = "Другая версия игры",
			sblt_cus_confirm_changes = "Подтвердите изменения",
			sblt_cus_returned_title = "Возвращено",
			sblt_cus_returned_text = "Вещи были возвращены в инвентарь.",
			sblt_cus_stashed_title = "Спрятано",
			sblt_cus_stashed_text = "Эти предметы спрятаны, поскольку они несовместимы с данной версией игры или модифицированы с использованием несовместимых предметов, и будут возвращены при запуске версии, в которой этот предмет будет доступен.",
			sblt_cus_slot_switched = "Слот был заменен.\n\nНайден слот, версия которого соответствует текущей версии игры.",
			sblt_cus_slot_not_found = "Нет ни одного слота, соответствующего текущей версии. Вы должны выбрать слот вручную.",
			sblt_cus_savefile_not_found = "Файл не может быть загружен: %s.\n\nВам будет предложено выбрать файл сохранения, из которого будут перенесены данные. Этот параметр не повлияет на ваши сохраненные файлы, он будет считывать только один из них и переносить данные оттуда в новую систему.После этого вы можете играть в любую версию игры без ущерба для ваших сохраненных данных.",
			sblt_cus_save_not_loaded = "Файл не может быть загружен: %s.",
			sblt_cus_port_from_savefile = "Вы уверены, что хотите портировать прогресс из файла %s?\n\nВаш текущий прогресс исчезнет.",
			sblt_cus_dialog_different_version = "Версия игры: %s\nВерсия сохранения: %s\n\nЭтот слот использовался в другой версии игры. Все недоступные предметы будут сохранены до тех пор, пока вы не вернетесь к версии, соответствующей этому слоту. Продолжить?",

		})
	end
end)

local data = LocalizationManager.text
function LocalizationManager:text(string_id, macros)
	string_id = string_id or ""
	return data(self, string_id, macros)
end