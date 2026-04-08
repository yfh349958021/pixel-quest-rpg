extends Node
## 存档管理器 - 读写 ~/save/ 目录

const SAVE_DIR := "user://saves/"
const SAVE_FILE := "save_data.json"

func _ready() -> void:
	# 确保存档目录存在
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_DIR + SAVE_FILE)

func save_game() -> bool:
	var data := GameManager.get_save_data()
	data["settings"] = SettingsManager.get_save_data()
	data["timestamp"] = Time.get_datetime_string_from_system()
	
	var file := FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.WRITE)
	if file == null:
		push_error("存档失败: %s" % FileAccess.get_open_error())
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

func load_game() -> bool:
	if not has_save():
		push_error("没有存档文件")
		return false
	
	var file := FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.READ)
	if file == null:
		push_error("读取存档失败: %s" % FileAccess.get_open_error())
		return false
	
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	
	if err != OK:
		push_error("存档JSON解析失败")
		return false
	
	var data = json.get_data()
	GameManager.load_save_data(data)
	
	if data.has("settings"):
		SettingsManager.load_save_data(data["settings"])
	
	return true

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_DIR + SAVE_FILE)

func get_save_info() -> Dictionary:
	if not has_save():
		return {}
	
	var file := FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.READ)
	if file == null:
		return {}
	
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
	
	var data = json.get_data()
	return {
		"timestamp": data.get("timestamp", ""),
		"game_phase": data.get("game_phase", 0),
		"current_map": data.get("current_map", "")
	}
