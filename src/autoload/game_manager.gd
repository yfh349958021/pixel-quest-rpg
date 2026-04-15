extends Node
## 游戏核心管理器

signal game_phase_changed(new_phase: int)
signal npc_status_changed(npc_name: String, new_status: String)
signal cg_gallery_changed
signal play_time_updated(total_seconds: int)

var game_phase: int = 0
var npc_statuses: Dictionary = {}
var inventory: Array = []
var unlocked_maps: Array = []
var current_map: String = ""
var current_map_id: int = 0
var is_game_started: bool = false
var player_position: Vector2 = Vector2(640, 360)
var unlocked_cgs: Array = []
var total_play_time: int = 0
var player_name: String = "林远"

var _play_time_timer: Timer = null

func _ready() -> void:
	_play_time_timer = Timer.new()
	_play_time_timer.name = "PlayTimeTimer"
	_play_time_timer.wait_time = 1.0
	_play_time_timer.one_shot = false
	_play_time_timer.timeout.connect(_on_play_time_tick)
	add_child(_play_time_timer)

func start_play_time() -> void:
	_play_time_timer.start()

func stop_play_time() -> void:
	_play_time_timer.stop()

func get_play_time_str() -> String:
	var h: int = total_play_time / 3600
	var m: int = (total_play_time % 3600) / 60
	var s: int = total_play_time % 60
	return "%02d:%02d:%02d" % [h, m, s]

func _on_play_time_tick() -> void:
	total_play_time += 1
	play_time_updated.emit(total_play_time)

func start_new_game() -> void:
	game_phase = 1
	npc_statuses.clear()
	inventory.clear()
	unlocked_maps.clear()
	unlocked_cgs.clear()
	total_play_time = 0
	is_game_started = true
	current_map = "蓝河村"
	current_map_id = 1  # Maps.MapID.LANHE_VILLAGE
	player_position = Vector2(20 * 32, 15 * 32)  # 蓝河村中心
	player_name = "林远"
	AffinityManager.reset()
	game_phase_changed.emit(1)

func set_game_phase(value: int) -> void:
	if game_phase != value:
		game_phase = value
		game_phase_changed.emit(value)

func set_npc_status(npc_name: String, status: String) -> void:
	npc_statuses[npc_name] = status
	npc_status_changed.emit(npc_name, status)

func get_npc_status(npc_name: String) -> String:
	return npc_statuses.get(npc_name, "default")

func set_current_map(map_name: String, map_id: int) -> void:
	current_map = map_name
	current_map_id = map_id

func add_to_inventory(item_id: String) -> void:
	inventory.append(item_id)

func remove_from_inventory(item_id: String) -> void:
	inventory.erase(item_id)

func has_inventory_item(item_id: String) -> bool:
	return item_id in inventory

func unlock_map(map_id: String) -> void:
	if map_id not in unlocked_maps:
		unlocked_maps.append(map_id)

func unlock_cg(cg_id: String) -> void:
	if cg_id not in unlocked_cgs:
		unlocked_cgs.append(cg_id)
		cg_gallery_changed.emit()

func get_save_data() -> Dictionary:
	return {
		"game_phase": game_phase,
		"npc_statuses": npc_statuses,
		"inventory": inventory,
		"unlocked_maps": unlocked_maps,
		"unlocked_cgs": unlocked_cgs,
		"current_map": current_map,
		"current_map_id": current_map_id,
		"player_position": {"x": player_position.x, "y": player_position.y},
		"total_play_time": total_play_time,
		"player_name": player_name,
		"affinities": AffinityManager.get_save_data(),
	}

func load_save_data(data: Dictionary) -> void:
	game_phase = data.get("game_phase", 0)
	npc_statuses = data.get("npc_statuses", {})
	inventory = data.get("inventory", [])
	unlocked_maps = data.get("unlocked_maps", [])
	unlocked_cgs = data.get("unlocked_cgs", [])
	current_map = data.get("current_map", "蓝河村")
	current_map_id = data.get("current_map_id", 1)
	var pos = data.get("player_position", {"x": 640, "y": 360})
	player_position = Vector2(pos.get("x", 640), pos.get("y", 360))
	total_play_time = data.get("total_play_time", 0)
	player_name = data.get("player_name", "林远")
	if player_name == "":
		player_name = "林远"
	is_game_started = true
	if data.has("affinities"):
		AffinityManager.load_save_data(data["affinities"])
