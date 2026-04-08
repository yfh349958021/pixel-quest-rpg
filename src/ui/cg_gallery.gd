extends Control
## CG画廊

@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var btn_left: Button = $VBoxContainer/HBox/BtnLeft
@onready var btn_right: Button = $VBoxContainer/HBox/BtnRight
@onready var btn_back: Button = $VBoxContainer/BtnBack
@onready var cg_display: TextureRect = $CGDisplay
@onready var cg_dialogue: Label = $CGDisplay/DialogueLabel

var _current_cg_index: int = 0
var _unlocked_cgs: Array = []

func _ready() -> void:
	_connect_signals()
	_refresh_gallery()
	CGGalleryManager.gallery_updated.connect(_refresh_gallery)

func _connect_signals() -> void:
	btn_left.pressed.connect(_on_left_pressed)
	btn_right.pressed.connect(_on_right_pressed)
	btn_back.pressed.connect(_on_back_pressed)

func _refresh_gallery() -> void:
	# 清空网格
	for child in grid.get_children():
		child.queue_free()
	
	_unlocked_cgs = CGGalleryManager.get_unlocked_cgs()
	
	# 创建CG缩略图
	for cg_id in _unlocked_cgs:
		var btn := Button.new()
		btn.text = cg_id.get_file().get_basename()
		btn.custom_minimum_size = Vector2(100, 80)
		btn.pressed.connect(_show_cg.bind(cg_id))
		grid.add_child(btn)
	
	# 如果没有解锁的CG
	if _unlocked_cgs.is_empty():
		var label := Label.new()
		label.text = "暂无解锁的CG"
		grid.add_child(label)

func _show_cg(cg_id: String) -> void:
	var path := "res://assets/sprites/cg/" + cg_id
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex:
			cg_display.texture = tex
			cg_display.visible = true

func _on_left_pressed() -> void:
	CGGalleryManager.input_left()

func _on_right_pressed() -> void:
	CGGalleryManager.input_right()

func _on_back_pressed() -> void:
	# 重置秘籍计数
	CGGalleryManager.reset_counter()
	SceneManager.goto_scene("res://scenes/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and cg_display.visible:
		cg_display.visible = false
		get_viewport().set_input_as_handled()
