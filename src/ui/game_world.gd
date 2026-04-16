extends Node2D
## 游戏世界场景

@onready var player: CharacterBody2D = $Player
@onready var map_container: Node2D = $MapContainer
@onready var dialogue_box: Control = $DialogueBox

var _system_menu: CanvasLayer = null
var _ready_done: bool = false

func _ready() -> void:
	# 第一步：解冻玩家（确保不会卡住）
	player.freeze_movement(false)
	push_warning("[GameWorld] 步骤1: 玩家解冻")
	
	# 第二步：加载地图
	MapManager.setup(map_container)
	MapManager.load_map(GameManager.current_map_id)
	push_warning("[GameWorld] 步骤2: 地图加载完成, map_id=" + str(GameManager.current_map_id))
	
	# 第三步：加载系统菜单
	var menu_scene: PackedScene = load("res://scenes/SystemMenu.tscn")
	if menu_scene:
		_system_menu = menu_scene.instantiate()
		add_child(_system_menu)
		push_warning("[GameWorld] 步骤3: 系统菜单加载完成")
	
	# 第四步：连接NPC信号
	_connect_npc_signals()
	
	# 第五步：设置玩家位置
	player.position = GameManager.player_position
	
	_ready_done = true
	push_warning("[GameWorld] 步骤5: _ready全部完成")
	
	# 确保SceneManager遮罩消失
	SceneManager._transition_rect.modulate.a = 0.0
	push_warning("[GameWorld] 步骤6: 清除场景切换遮罩")
	
	# 监听后续地图切换
	MapManager.map_loaded.connect(_on_map_loaded)

func _connect_npc_signals() -> void:
	for npc: Node in MapManager.get_current_npcs():
		if npc.has_signal("dialogue_requested"):
			if not npc.dialogue_requested.is_connected(_on_npc_dialogue_requested):
				npc.dialogue_requested.connect(_on_npc_dialogue_requested)

func _on_map_loaded(_map_id: int, _map_name: String) -> void:
	await get_tree().process_frame
	_connect_npc_signals()

func _unhandled_input(event: InputEvent) -> void:
	if not _ready_done or not _system_menu:
		return
	if event.is_action_pressed("ui_cancel"):
		if _system_menu.visible or dialogue_box.visible:
			return
		_system_menu.open_menu()
		get_viewport().set_input_as_handled()

func _on_npc_dialogue_requested(npc: Node) -> void:
	player.freeze_movement(true)
	dialogue_box.show_for_npc(npc)

func _on_dialogue_finished() -> void:
	player.freeze_movement(false)
