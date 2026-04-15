extends Node2D
## 游戏世界场景

@onready var player: CharacterBody2D = $Player
@onready var npcs_container: Node2D = $NPCs
@onready var dialogue_box: Control = $DialogueBox

var _system_menu: Control = null
var _npc_nearby: Node = null

func _ready() -> void:
	# 加载系统菜单
	var menu_scene: PackedScene = load("res://scenes/SystemMenu.tscn")
	if menu_scene:
		_system_menu = menu_scene.instantiate()
		add_child(_system_menu)
	
	# 连接NPC交互信号
	for npc: Node in npcs_container.get_children():
		if npc.has_signal("dialogue_requested"):
			npc.dialogue_requested.connect(_on_npc_dialogue_requested)
	
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	
	# 设置玩家位置
	player.position = GameManager.player_position

func _process(_delta: float) -> void:
	# ESC键打开系统菜单
	if Input.is_action_just_pressed("ui_cancel"):
		if dialogue_box.visible:
			dialogue_box.hide()
		elif _system_menu and not _system_menu.visible:
			_system_menu.open_menu()
	
	# 检测附近NPC
	_check_nearby_npc()

func _check_nearby_npc() -> void:
	_npc_nearby = null
	if not player or not player.has_node("InteractionArea"):
		return
	var area: Area2D = player.get_node("InteractionArea")
	var bodies: Array = area.get_overlapping_bodies()
	for body in bodies:
		if body is CharacterBody2D and body != player and body.is_in_group("npcs"):
			_npc_nearby = body
			break

func _on_npc_dialogue_requested(npc: Node) -> void:
	dialogue_box.show_for_npc(npc)

func _on_dialogue_finished() -> void:
	pass
