extends Control
## 主菜单

@onready var btn_start: Button = $VBoxContainer/BtnStart
@onready var btn_continue: Button = $VBoxContainer/BtnContinue
@onready var btn_gallery: Button = $VBoxContainer/BtnGallery
@onready var btn_settings: Button = $VBoxContainer/BtnSettings
@onready var btn_exit: Button = $VBoxContainer/BtnExit
@onready var title_label: Label = $TitleLabel

func _ready() -> void:
	# 更新按钮文字
	_update_texts()
	
	# 检查存档，决定"继续游戏"是否可用
	btn_continue.disabled = not SaveManager.has_save()
	
	# 连接信号
	btn_start.pressed.connect(_on_start_pressed)
	btn_continue.pressed.connect(_on_continue_pressed)
	btn_gallery.pressed.connect(_on_gallery_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	# 监听语言变化
	SettingsManager.language_changed.connect(_update_texts)

func _update_texts() -> void:
	btn_start.text = LocalizationManager.get_text("start_game")
	btn_continue.text = LocalizationManager.get_text("continue_game")
	btn_gallery.text = LocalizationManager.get_text("view_gallery")
	btn_settings.text = LocalizationManager.get_text("settings")
	btn_exit.text = LocalizationManager.get_text("exit_game")
	btn_continue.disabled = not SaveManager.has_save()

func _on_start_pressed() -> void:
	# 开始新游戏
	GameManager.start_new_game()
	SceneManager.goto_scene("res://scenes/GameWorld.tscn")

func _on_continue_pressed() -> void:
	if SaveManager.load_game():
		SceneManager.goto_scene("res://scenes/GameWorld.tscn")

func _on_gallery_pressed() -> void:
	SceneManager.goto_scene("res://scenes/CGGallery.tscn")

func _on_settings_pressed() -> void:
	SceneManager.goto_scene("res://scenes/Settings.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
