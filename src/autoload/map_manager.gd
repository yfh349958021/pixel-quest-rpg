extends Node
## 地图管理器 - 管理地图加载、NPC生成、传送区域

const MapsDB = preload("res://data/maps.gd")
const TILE_SIZE: int = 32

var current_map_id: int = -1
var _map_container: Node2D = null
var _npc_container: Node2D = null
var _transfer_container: Node2D = null
var _wall_body: StaticBody2D = null
var _is_transitioning: bool = false

signal map_loaded(map_id: int, map_name: String)
signal map_transition_started()
signal map_transition_finished()

## 地图名 → 背景图路径
const MAP_BACKGROUNDS: Dictionary = {
	1: "res://assets/tilesets/蓝河村.png",
	2: "res://assets/tilesets/村外平原.png",
	3: "res://assets/tilesets/风岩城街道.png",
	4: "res://assets/tilesets/风岩城市场.png",
	5: "res://assets/tilesets/酒馆.png",
	6: "res://assets/tilesets/教堂.png",
	7: "res://assets/tilesets/北方冰原.png",
	8: "res://assets/tilesets/永恒王国.png",
	9: "res://assets/tilesets/永夜森林边缘.png",
	10: "res://assets/tilesets/永夜森林深处.png",
	11: "res://assets/tilesets/金贸王国.png",
	12: "res://assets/tilesets/无尽海岛屿.png",
}

func setup(container: Node2D) -> void:
	_map_container = container

func load_map(map_id: int) -> void:
	if _map_container == null:
		return
	var map_data: Dictionary = MapsDB.get_map(map_id)
	if map_data.is_empty():
		push_error("地图ID不存在: %d" % map_id)
		return
	_clear_map()
	current_map_id = map_id
	GameManager.current_map_id = map_id
	GameManager.current_map = map_data.get("name_cn", "")
	_create_background(map_data, map_id)
	_create_boundary_walls(map_data)
	_spawn_npcs(map_data)
	_create_transfers(map_data)
	map_loaded.emit(map_id, map_data.get("name_cn", ""))

func _clear_map() -> void:
	if _map_container:
		for child in _map_container.get_children():
			child.queue_free()
	_npc_container = null
	_transfer_container = null
	_wall_body = null

func _create_background(map_data: Dictionary, map_id: int) -> void:
	var size_x: int = map_data.get("size_x", 40) * TILE_SIZE
	var size_y: int = map_data.get("size_y", 30) * TILE_SIZE
	
	# 尝试加载实际背景图
	var bg_path: String = MAP_BACKGROUNDS.get(map_id, "")
	if bg_path != "":
		var tex: Texture2D = _load_texture_from_path(bg_path)
		if tex:
			var sprite := Sprite2D.new()
			sprite.name = "MapBackground"
			sprite.texture = tex
			sprite.scale = Vector2(
				float(size_x) / tex.get_width(),
				float(size_y) / tex.get_height()
			)
			sprite.z_index = -10
			_map_container.add_child(sprite)
			# 地图名称标签
			var label := Label.new()
			label.text = map_data.get("name_cn", "")
			label.position = Vector2(10, 10)
			label.z_index = 5
			_map_container.add_child(label)
			return
	
	# 回退：彩色背景
	var bg := ColorRect.new()
	bg.name = "MapBackground"
	bg.size = Vector2(size_x, size_y)
	bg.color = _get_map_color(map_data.get("tileset", ""))
	bg.z_index = -10
	_map_container.add_child(bg)

func _get_map_color(tileset: String) -> Color:
	match tileset:
		"village": return Color(0.35, 0.55, 0.25)
		"plain": return Color(0.45, 0.65, 0.30)
		"city_street": return Color(0.55, 0.50, 0.40)
		"city_market": return Color(0.50, 0.45, 0.35)
		"tavern": return Color(0.40, 0.30, 0.25)
		"church": return Color(0.45, 0.40, 0.50)
		"ice_path": return Color(0.75, 0.80, 0.85)
		"eternal": return Color(0.35, 0.35, 0.45)
		"dark_forest": return Color(0.15, 0.30, 0.15)
		"dark_forest_deep": return Color(0.10, 0.20, 0.10)
		"goldtrade": return Color(0.60, 0.50, 0.30)
		"island": return Color(0.50, 0.40, 0.35)
		_: return Color(0.3, 0.3, 0.3)

func _create_boundary_walls(map_data: Dictionary) -> void:
	var size_x: int = map_data.get("size_x", 40) * TILE_SIZE
	var size_y: int = map_data.get("size_y", 30) * TILE_SIZE
	var thickness: float = 16.0
	_wall_body = StaticBody2D.new()
	_wall_body.name = "MapWalls"
	_wall_body.collision_layer = 4
	_wall_body.collision_mask = 0
	_add_wall_rect(_wall_body, Vector2(0, -thickness), Vector2(size_x + thickness * 2, thickness))
	_add_wall_rect(_wall_body, Vector2(0, size_y), Vector2(size_x + thickness * 2, thickness))
	_add_wall_rect(_wall_body, Vector2(-thickness, 0), Vector2(thickness, size_y))
	_add_wall_rect(_wall_body, Vector2(size_x, 0), Vector2(thickness, size_y))
	_map_container.add_child(_wall_body)

func _add_wall_rect(parent: Node2D, pos: Vector2, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var cs := CollisionShape2D.new()
	cs.position = pos + size / 2.0
	cs.shape = shape
	parent.add_child(cs)

func _spawn_npcs(map_data: Dictionary) -> void:
	var npcs_data: Array = map_data.get("npcs", [])
	_npc_container = Node2D.new()
	_npc_container.name = "NPCs"
	var npc_script: GDScript = load("res://src/core/npc.gd")
	for npc_data in npcs_data:
		var npc := CharacterBody2D.new()
		npc.name = "NPC_" + npc_data["name"]
		npc.position = Vector2(npc_data["x"] * TILE_SIZE, npc_data["y"] * TILE_SIZE)
		npc.set_meta("npc_name", npc_data["name"])
		npc.set_meta("is_core", npc_data.get("is_core", false))
		npc.collision_layer = 2
		npc.collision_mask = 1
		var body_shape := CircleShape2D.new()
		body_shape.radius = 16.0
		var body_cs := CollisionShape2D.new()
		body_cs.shape = body_shape
		npc.add_child(body_cs)
		# 行走图sprite
		var sprite := Sprite2D.new()
		sprite.name = "Sprite2D"
		sprite.scale = Vector2(2.0, 2.0)
		var npc_name: String = npc_data["name"]
		var sprite_path: String = "res://assets/characters/npcs/%s.png" % npc_name
		var tex: Texture2D = _load_texture_from_path(sprite_path)
		if tex:
			sprite.texture = tex
			# 设置hframes/vframes为spritesheet格式 (4x4)
			sprite.hframes = 4
			sprite.vframes = 4
			sprite.frame = 0  # 默认朝下
		else:
			# 回退：彩色方块
			var is_core: bool = npc_data.get("is_core", false)
			sprite.modulate = Color(0.8, 0.5, 0.9, 1) if is_core else Color(0.5, 0.5, 0.5, 1)
		npc.add_child(sprite)
		# NPC名称标签
		var label := Label.new()
		label.name = "NameLabel"
		label.text = npc_name
		label.position = Vector2(-20, -24)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.z_index = 5
		npc.add_child(label)
		npc.set_script(npc_script)
		npc.npc_name = npc_name
		npc.is_core_character = npc_data.get("is_core", false)
		_npc_container.add_child(npc)
	_map_container.add_child(_npc_container)

func _create_transfers(map_data: Dictionary) -> void:
	var transfers: Array = map_data.get("transfers", [])
	_transfer_container = Node2D.new()
	_transfer_container.name = "Transfers"
	for transfer in transfers:
		var target_map: int = transfer.get("target_map", -1)
		if target_map == -1:
			continue
		var area := Area2D.new()
		area.name = "Transfer_" + str(target_map)
		var w: float = transfer["w"] * TILE_SIZE
		var h: float = transfer["h"] * TILE_SIZE
		area.position = Vector2(
			transfer["x"] * TILE_SIZE + w / 2.0,
			transfer["y"] * TILE_SIZE + h / 2.0
		)
		area.collision_layer = 0
		area.collision_mask = 1
		var shape := RectangleShape2D.new()
		shape.size = Vector2(w, h)
		var cs := CollisionShape2D.new()
		cs.shape = shape
		area.add_child(cs)
		var label := Label.new()
		label.text = transfer.get("label", "")
		label.position = Vector2(0, -15)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.z_index = 5
		area.add_child(label)
		area.set_meta("target_map", target_map)
		area.set_meta("target_x", transfer.get("target_x", 0))
		area.set_meta("target_y", transfer.get("target_y", 0))
		area.set_meta("label", transfer.get("label", ""))
		area.body_entered.connect(_on_transfer_entered.bind(area))
		_transfer_container.add_child(area)
	_map_container.add_child(_transfer_container)

func _on_transfer_entered(body: Node2D, area: Area2D) -> void:
	if _is_transitioning:
		return
	if body.name != "Player":
		return
	_is_transitioning = true
	var target_map: int = area.get_meta("target_map")
	var target_x: int = area.get_meta("target_x")
	var target_y: int = area.get_meta("target_y")
	map_transition_started.emit()
	var tween: Tween = create_tween()
	tween.tween_callback(func(): SceneManager._transition_rect.modulate.a = 0.0)
	tween.tween_property(SceneManager._transition_rect, "modulate:a", 1.0, 0.3)
	await tween.finished
	load_map(target_map)
	body.position = Vector2(target_x * TILE_SIZE, target_y * TILE_SIZE)
	GameManager.player_position = body.position
	var tween2: Tween = create_tween()
	tween2.tween_property(SceneManager._transition_rect, "modulate:a", 0.0, 0.3)
	await tween2.finished
	_is_transitioning = false
	map_transition_finished.emit()

func get_current_npcs() -> Array:
	if _npc_container:
		return _npc_container.get_children()
	return []
func _load_texture_from_path(path: String) -> Texture2D:
	"""直接从文件加载纹理，不依赖import缓存"""
	var file_path: String = path.replace("res://", ProjectSettings.globalize_path("res://"))
	if not FileAccess.file_exists(file_path):
		return null
	var img := Image.load_from_file(file_path)
	if img == null:
		return null
	return ImageTexture.create_from_image(img)

func get_map_size_pixels(map_id: int) -> Vector2:
	var data: Dictionary = MapsDB.get_map(map_id)
	if data.is_empty():
		return Vector2(1280, 720)
	return Vector2(
		data.get("size_x", 40) * TILE_SIZE,
		data.get("size_y", 30) * TILE_SIZE
	)
