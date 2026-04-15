extends Node2D
## 游戏世界场景

@onready var player: CharacterBody2D = $Player
@onready var npcs_container: Node2D = $NPCs
@onready var dialogue_box: Control = $DialogueBox

var _system_menu: CanvasLayer = null

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
	if player:
		player.position = GameManager.player_position

func _unhandled_input(event: InputEvent) -> void:
	# BUG修复: 用_unhandled_input，这样dialogue_box._input消费后这里不会重复处理
	if not _system_menu or not _system_menu.visible:
		# 系统菜单未打开时才处理ESC
		if event.is_action_pressed("ui_cancel"):
			if dialogue_box.visible:
				# BUG修复: 对话框打开时ESC应该让dialogue_box自己处理（end_dialogue）
				# 不需要在这里手动hide，dialogue_box._input已经处理了
				pass
			else:
				# 打开系统菜单
				_system_menu.open_menu()
				get_viewport().set_input_as_handled()

func _on_npc_dialogue_requested(npc: Node) -> void:
	dialogue_box.show_for_npc(npc)

func _on_dialogue_finished() -> void:
	pass
