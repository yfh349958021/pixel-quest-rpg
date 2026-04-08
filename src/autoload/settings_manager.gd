extends Node
## 设置管理器 - 分辨率、显示模式、语言

enum Language { CN, JP }

# 支持的分辨率
const RESOLUTIONS := {
	"4K": Vector2i(3840, 2160),
	"2K": Vector2i(2560, 1440),
	"1080p": Vector2i(1920, 1080),
	"720p": Vector2i(1280, 720),
}

# 当前设置
var resolution_name: String = "720p"
var display_mode: int = 0  # 0=窗口化, 1=无边框, 2=全屏
var current_language: Language = Language.CN

signal language_changed(new_lang: Language)
signal settings_changed

func _ready() -> void:
	load_settings()
	apply_settings()

func set_resolution(name: String) -> void:
	if RESOLUTIONS.has(name):
		resolution_name = name
		apply_settings()
		save_settings()

func set_display_mode(mode: int) -> void:
	display_mode = mode
	apply_settings()
	save_settings()

func set_language(lang: Language) -> void:
	current_language = lang
	language_changed.emit(lang)
	save_settings()

func get_language_suffix() -> String:
	match current_language:
		Language.CN:
			return "_cn"
		Language.JP:
			return "_jp"
	return "_cn"

func get_language_name() -> String:
	match current_language:
		Language.CN:
			return "简体中文"
		Language.JP:
			return "日本語"
	return "简体中文"

func apply_settings() -> void:
	# 应用分辨率
	var res = RESOLUTIONS.get(resolution_name, RESOLUTIONS["720p"])
	get_viewport().size = res
	
	# 应用显示模式
	match display_mode:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	settings_changed.emit()

func get_save_data() -> Dictionary:
	return {
		"resolution": resolution_name,
		"display_mode": display_mode,
		"language": current_language
	}

func load_save_data(data: Dictionary) -> void:
	resolution_name = data.get("resolution", "720p")
	display_mode = data.get("display_mode", 0)
	current_language = data.get("language", Language.CN)
	apply_settings()

func save_settings() -> void:
	var file := FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(get_save_data()))
		file.close()

func load_settings() -> void:
	if FileAccess.file_exists("user://settings.json"):
		var file := FileAccess.open("user://settings.json", FileAccess.READ)
		if file:
			var json := JSON.new()
			if json.parse(file.get_as_text()) == OK:
				load_save_data(json.get_data())
			file.close()
