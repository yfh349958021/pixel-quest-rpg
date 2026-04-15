extends Node
## 存档管理器 - 9个存档槽位 + 自动保存

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 9
const AUTO_SAVE_SLOT := 0
const AUTO_SAVE_INTERVAL := 60.0

var _auto_save_timer: Timer = null

signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_auto_save_timer = Timer.new()
	_auto_save_timer.name = "AutoSaveTimer"
	_auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	_auto_save_timer.one_shot = false
	_auto_save_timer.timeout.connect(_on_auto_save)
	add_child(_auto_save_timer)

func start_auto_save() -> void:
	_auto_save_timer.start()

func stop_auto_save() -> void:
	_auto_save_timer.stop()

func get_auto_save_time_left() -> float:
	return _auto_save_timer.time_left

## 获取某个槽位的存档信息
func get_slot_info(slot: int) -> Dictionary:
	var path: String = _get_slot_path(slot)
	if not FileAccess.file_exists(path):
		return {"exists": false, "slot": slot, "is_auto": slot == AUTO_SAVE_SLOT}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {"exists": false, "slot": slot, "is_auto": slot == AUTO_SAVE_SLOT}
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return {"exists": false, "slot": slot, "is_auto": slot == AUTO_SAVE_SLOT}
	file.close()
	var data = json.get_data()
	if not data is Dictionary:
		return {"exists": false, "slot": slot, "is_auto": slot == AUTO_SAVE_SLOT}
	var map_name: String = data.get("current_map", "未知位置")
	var total_seconds: int = data.get("total_play_time", 0)
	return {
		"exists": true,
		"slot": slot,
		"is_auto": slot == AUTO_SAVE_SLOT,
		"timestamp": data.get("timestamp", ""),
		"game_phase": data.get("game_phase", 0),
		"current_map": map_name,
		"play_time": total_seconds,
		"play_time_str": _format_time(total_seconds),
	}

func get_all_slots_info() -> Array:
	var result: Array = []
	for i in range(MAX_SLOTS):
		result.append(get_slot_info(i))
	return result

func save_to_slot(slot: int) -> bool:
	var data: Dictionary = GameManager.get_save_data()
	data["settings"] = SettingsManager.get_save_data()
	data["timestamp"] = Time.get_datetime_string_from_system()
	data["slot"] = slot
	var path: String = _get_slot_path(slot)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("存档失败(槽位%d): %s" % [slot, FileAccess.get_open_error()])
		save_completed.emit(slot, false)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	save_completed.emit(slot, true)
	return true

func load_from_slot(slot: int) -> bool:
	var path: String = _get_slot_path(slot)
	if not FileAccess.file_exists(path):
		push_error("槽位%d没有存档" % slot)
		load_completed.emit(slot, false)
		return false
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		load_completed.emit(slot, false)
		return false
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		load_completed.emit(slot, false)
		return false
	file.close()
	var data = json.get_data()
	if not data is Dictionary:
		load_completed.emit(slot, false)
		return false
	GameManager.load_save_data(data)
	if data.has("settings"):
		SettingsManager.load_save_data(data["settings"])
	load_completed.emit(slot, true)
	return true

func delete_slot(slot: int) -> bool:
	var path: String = _get_slot_path(slot)
	if FileAccess.file_exists(path):
		return DirAccess.remove_absolute(path) == OK
	return true

func has_any_save() -> bool:
	for i in range(MAX_SLOTS):
		if get_slot_info(i).get("exists", false):
			return true
	return false

## 获取最近保存的存档槽位
func get_latest_slot() -> int:
	var latest_slot: int = -1
	var latest_ts: String = ""
	for i in range(MAX_SLOTS):
		var info: Dictionary = get_slot_info(i)
		if info.get("exists", false):
			var ts: String = info.get("timestamp", "")
			if ts > latest_ts:
				latest_ts = ts
				latest_slot = i
	return latest_slot

func _on_auto_save() -> void:
	save_to_slot(AUTO_SAVE_SLOT)

func _format_time(seconds: int) -> String:
	var h: int = seconds / 3600
	var m: int = (seconds % 3600) / 60
	var s: int = seconds % 60
	return "%02d:%02d:%02d" % [h, m, s]

func _get_slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%02d.json" % slot
