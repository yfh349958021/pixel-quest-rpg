extends Control
## 主菜单

@onready var btn_start: Button = $VBoxContainer/BtnStart
@onready var btn_continue: Button = $VBoxContainer/BtnContinue
@onready var btn_gallery: Button = $VBoxContainer/BtnGallery
@onready var btn_settings: Button = $VBoxContainer/BtnSettings
@onready var btn_exit: Button = $VBoxContainer/BtnExit
@onready var title_label: Label = $TitleLabel

func _ready() -> void:
	_update_texts()
	btn_continue.disabled = not SaveManager.has_any_save()
	btn_start.pressed.connect(_on_start_pressed)
	btn_continue.pressed.connect(_on_continue_pressed)
	btn_gallery.pressed.connect(_on_gallery_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	SettingsManager.language_changed.connect(_update_texts)

func _update_texts() -> void:
	btn_start.text = "开始游戏"
	btn_continue.text = "继续游戏"
	btn_gallery.text = "查看回想"
	btn_settings.text = "修改设置"
	btn_exit.text = "退出游戏"
	btn_continue.disabled = not SaveManager.has_any_save()

func _on_start_pressed() -> void:
	GameManager.start_new_game()
	SaveManager.start_auto_save()
	GameManager.start_play_time()
	SceneManager.goto_scene("res://scenes/GameWorld.tscn")

func _on_continue_pressed() -> void:
	# BUG修复: 直接加载最新存档进入游戏(保持简单)
	# 如果需要选择槽位，可以改为进入存档选择界面
	var slot: int = SaveManager.get_latest_slot()
	if slot >= 0:
		SaveManager.load_from_slot(slot)
		SaveManager.start_auto_save()
		GameManager.start_play_time()
		SceneManager.goto_scene("res://scenes/GameWorld.tscn")

func _on_gallery_pressed() -> void:
	SceneManager.goto_scene("res://scenes/RecallRoom.tscn")

func _on_settings_pressed() -> void:
	SceneManager.goto_scene("res://scenes/Settings.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
