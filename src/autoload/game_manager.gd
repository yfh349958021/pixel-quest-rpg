extends Node
## 游戏核心管理器 - 管理玩家状态、游戏阶段、NPC状态

signal game_phase_changed(new_phase: int)
signal npc_status_changed(npc_name: String, new_status: String)

# 玩家状态
var game_phase: int = 0 :  # 0=初始(未开始), 1,2,3...
	set(value):
		game_phase = value
		game_phase_changed.emit(value)

# NPC状态字典: { npc_name: status_string }
var npc_statuses: Dictionary = {}

# 玩家背包
var inventory: Array = []

# 已解锁关卡
var unlocked_maps: Array = []

# 当前地图
var current_map: String = ""

# 游戏是否在进行中
var is_game_started: bool = false

# 玩家在地图中的位置
var player_position: Vector2 = Vector2.ZERO

# 已解锁的CG列表
var unlocked_cgs: Array = []

func _ready() -> void:
	pass

func start_new_game() -> void:
	game_phase = 1
	npc_statuses.clear()
	inventory.clear()
	unlocked_maps.clear()
	unlocked_cgs.clear()
	is_game_started = true
	current_map = "map_01"
	player_position = Vector2(640, 360)

func set_npc_status(npc_name: String, status: String) -> void:
	npc_statuses[npc_name] = status
	npc_status_changed.emit(npc_name, status)

func get_npc_status(npc_name: String) -> String:
	return npc_statuses.get(npc_name, "default")

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

signal cg_gallery_changed

func get_save_data() -> Dictionary:
	return {
		"game_phase": game_phase,
		"npc_statuses": npc_statuses,
		"inventory": inventory,
		"unlocked_maps": unlocked_maps,
		"unlocked_cgs": unlocked_cgs,
		"current_map": current_map,
		"player_position": {"x": player_position.x, "y": player_position.y}
	}

func load_save_data(data: Dictionary) -> void:
	game_phase = data.get("game_phase", 0)
	npc_statuses = data.get("npc_statuses", {})
	inventory = data.get("inventory", [])
	unlocked_maps = data.get("unlocked_maps", [])
	unlocked_cgs = data.get("unlocked_cgs", [])
	current_map = data.get("current_map", "map_01")
	var pos = data.get("player_position", {"x": 640, "y": 360})
	player_position = Vector2(pos.get("x", 640), pos.get("y", 360))
	is_game_started = true
