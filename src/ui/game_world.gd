extends Node2D
## 游戏世界场景

@onready var player: CharacterBody2D = $Player
@onready var map_container: Node2D = $MapContainer
@onready var dialogue_box: Control = $DialogueBox

var _system_menu: CanvasLayer = null
var _ready_done: bool = false

func _ready() -> void:
	player.freeze_movement(false)
	
	MapManager.setup(map_container)
	MapManager.load_map(GameManager.current_map_id)
	
	# 加载系统菜单
	var menu_scene: PackedScene = load("res://scenes/SystemMenu.tscn")
	if menu_scene:
		_system_menu = menu_scene.instantiate()
		add_child(_system_menu)
	
	# 连接玩家交互信号 → 玩家按空格时触发NPC对话
	player.interact_requested.connect(_on_player_interact)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	
	# 设置玩家位置
	player.position = GameManager.player_position
	
	_ready_done = true
	
	# 确保场景切换遮罩消失
	if SceneManager._transition_rect:
		SceneManager._transition_rect.modulate.a = 0.0
	
	MapManager.map_loaded.connect(_on_map_loaded)

func _on_map_loaded(_map_id: int, _map_name: String) -> void:
	await get_tree().process_frame

func _unhandled_input(event: InputEvent) -> void:
	if not _ready_done or not _system_menu:
		return
	if event.is_action_pressed("ui_cancel"):
		if _system_menu.visible or dialogue_box.visible:
			return
		_system_menu.open_menu()
		get_viewport().set_input_as_handled()

func _on_player_interact(npc: Node2D) -> void:
	player.freeze_movement(true)
	dialogue_box.show_for_npc(npc)

func _on_dialogue_finished() -> void:
	player.freeze_movement(false)
