extends Node2D
## 游戏世界场景

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: Control = $DialogueBox

func _ready() -> void:
	player.interact_with_npc.connect(_on_player_interact)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	
	# 加载地图
	_load_current_map()

func _load_current_map() -> void:
	# 根据GameManager.current_map加载对应地图数据
	# 这里需要读取data/maps/下的配置文件
	pass

func _on_player_interact(npc: Node) -> void:
	dialogue_box.show_for_npc(npc)

func _on_dialogue_finished() -> void:
	pass

func _input(event: InputEvent) -> void:
	# ESC暂停游戏
	if event.is_action_pressed("ui_cancel") and not DialogueManager.is_active:
		_pause_game()
		get_viewport().set_input_as_handled()

func _pause_game() -> void:
	# 保存游戏
	SaveManager.save_game()
	# 返回主菜单
	SceneManager.goto_scene("res://scenes/MainMenu.tscn")
