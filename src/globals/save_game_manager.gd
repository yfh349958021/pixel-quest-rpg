extends Node

var allow_save_game: bool = false
var save_path: String = "user://save_data.json"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game") and allow_save_game:
		save_game()

func save_game() -> void:
	var data = {
		"inventory": InventoryManager.inventory,
		"day": DayAndNightCycleManager.current_day,
		"hour": int(DayAndNightCycleManager.time / DayAndNightCycleManager.GAME_MINUTE_DURATION) % 24,
		"player_pos_x": 0.0,
		"player_pos_y": 0.0,
	}
	var player = get_tree().get_first_node_in_group("player")
	if player:
		data["player_pos_x"] = player.global_position.x
		data["player_pos_y"] = player.global_position.y
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		return
	if data.has("inventory"):
		InventoryManager.inventory = data["inventory"]
		InventoryManager.inventory_changed.emit()
	if data.has("day"):
		DayAndNightCycleManager.initial_day = data["day"]
	if data.has("hour"):
		DayAndNightCycleManager.initial_hour = data["hour"]
	DayAndNightCycleManager.set_initial_time()
