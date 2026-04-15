extends Control
## 主角名称输入

@onready var name_edit: LineEdit = $VBox/NameEdit
@onready var btn_confirm: Button = $VBox/BtnConfirm

func _ready() -> void:
	btn_confirm.pressed.connect(_on_confirm)
	name_edit.text_submitted.connect(_on_confirm)
	# 延迟一帧让LineEdit获得焦点
	await get_tree().process_frame
	name_edit.grab_focus()

func _on_confirm(_text: String = "") -> void:
	var name: String = name_edit.text.strip_edges()
	if name == "":
		name = "林远"
	GameManager.player_name = name
	SaveManager.start_auto_save()
	GameManager.start_play_time()
	SceneManager.goto_scene("res://scenes/GameWorld.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and name_edit.has_focus():
		_on_confirm()
		get_viewport().set_input_as_handled()
