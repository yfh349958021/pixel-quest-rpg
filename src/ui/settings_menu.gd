extends Control
## 设置菜单

@onready var option_resolution: OptionButton = $VBoxContainer/ResolutionBox/OptionResolution
@onready var option_display: OptionButton = $VBoxContainer/DisplayBox/OptionDisplay
@onready var option_language: OptionButton = $VBoxContainer/LanguageBox/OptionLanguage
@onready var btn_back: Button = $VBoxContainer/BtnBack

var _resolution_keys := ["720p", "1080p", "2K", "4K"]
var _display_modes := ["windowed", "borderless", "fullscreen"]
var _languages := ["cn", "jp"]

func _ready() -> void:
	_setup_options()
	_load_current_settings()
	_connect_signals()

func _setup_options() -> void:
	# 分辨率选项
	option_resolution.clear()
	for key in _resolution_keys:
		option_resolution.add_item(key)
	
	# 显示模式选项
	option_display.clear()
	for mode in _display_modes:
		option_display.add_item(LocalizationManager.get_text(mode))
	
	# 语言选项
	option_language.clear()
	option_language.add_item("简体中文")
	option_language.add_item("日本語")

func _load_current_settings() -> void:
	# 分辨率
	var res_idx = _resolution_keys.find(SettingsManager.resolution_name)
	if res_idx >= 0:
		option_resolution.selected = res_idx
	
	# 显示模式
	option_display.selected = SettingsManager.display_mode
	
	# 语言
	option_language.selected = SettingsManager.current_language

func _connect_signals() -> void:
	option_resolution.item_selected.connect(_on_resolution_changed)
	option_display.item_selected.connect(_on_display_changed)
	option_language.item_selected.connect(_on_language_changed)
	btn_back.pressed.connect(_on_back_pressed)

func _on_resolution_changed(index: int) -> void:
	SettingsManager.set_resolution(_resolution_keys[index])

func _on_display_changed(index: int) -> void:
	SettingsManager.set_display_mode(index)

func _on_language_changed(index: int) -> void:
	SettingsManager.set_language(index)

func _on_back_pressed() -> void:
	SceneManager.goto_scene("res://scenes/MainMenu.tscn")
