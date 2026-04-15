extends Node2D
## 游戏世界场景

@onready var player: CharacterBody2D = $Player
@onready var map_container: Node2D = $MapContainer
@onready var dialogue_box: Control = $DialogueBox

var _system_menu: CanvasLayer = null

func _ready() -> void:
	# 初始化MapManager
	MapManager.setup(map_container)
	# 加载系统菜单
	var menu_scene: PackedScene = load("res://scenes/SystemMenu.tscn")
	if menu_scene:
		_system_menu = menu_scene.instantiate()
		add_child(_system_menu)
	# 连接NPC交互信号(延迟连接，等MapManager生成NPC后)
	await MapManager.map_loaded
	_connect_npc_signals()
	# 设置玩家位置
	player.position = GameManager.player_position
	player.freeze_movement(false)

func _connect_npc_signals() -> void:
	for npc: Node in MapManager.get_current_npcs():
		if npc.has_signal("dialogue_requested"):
			if not npc.dialogue_requested.is_connected(_on_npc_dialogue_requested):
				npc.dialogue_requested.connect(_on_npc_dialogue_requested)
	# 监听后续地图切换的NPC生成
	if not MapManager.map_loaded.is_connected(_on_map_loaded):
		MapManager.map_loaded.connect(_on_map_loaded)

func _on_map_loaded(_map_id: int, _map_name: String) -> void:
	# 地图切换后重新连接NPC信号
	await get_tree().process_frame
	_connect_npc_signals()

func _unhandled_input(event: InputEvent) -> void:
	if not _system_menu or not _system_menu.visible:
		if event.is_action_pressed("ui_cancel"):
			if dialogue_box.visible:
				pass  # dialogue_box自己处理
			else:
				_system_menu.open_menu()
				get_viewport().set_input_as_handled()

func _on_npc_dialogue_requested(npc: Node) -> void:
	player.freeze_movement(true)
	dialogue_box.show_for_npc(npc)

func _on_dialogue_finished() -> void:
	player.freeze_movement(false)
