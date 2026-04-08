extends Node
## 本地化管理器

var _text_table: Dictionary = {}

func _ready() -> void:
	load_translations()

func load_translations() -> void:
	_text_table.clear()
	var files: Array = [
		"res://data/i18n_cn.csv",
		"res://data/i18n_jp.csv"
	]
	for path: String in files:
		if FileAccess.file_exists(path):
			_load_csv(path)

func _load_csv(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var first_line: bool = true
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line.is_empty():
			continue
		if first_line:
			first_line = false
			continue
		var parts: PackedStringArray = line.split(",")
		if parts.size() >= 3:
			var key: String = parts[0].strip_edges()
			_text_table[key] = {"cn": parts[1].strip_edges(), "jp": parts[2].strip_edges()}
	file.close()

func get_text(key: String) -> String:
	if _text_table.has(key):
		var lang_key: String = "_cn" if SettingsManager.current_language == 0 else "_jp"
		var result: Variant = _text_table[key].get(lang_key, "")
		if result != "":
			return str(result)
	return key

func find_audio(base_name: String) -> String:
	var lang_suffix: String = SettingsManager.get_language_suffix()
	var fallback: String = "_jp" if lang_suffix == "_cn" else "_cn"
	var extensions: Array = [".ogg", ".mp3", ".wav"]
	for suf: String in [lang_suffix, fallback]:
		for ext: String in extensions:
			var p: String = "res://assets/audio/dialogue/" + base_name + suf + ext
			if ResourceLoader.exists(p):
				return p
	return ""

func find_portrait(base_name: String) -> String:
	for ext: String in [".png", ".jpg", ".webp"]:
		var p: String = "res://assets/sprites/portraits/" + base_name + ext
		if ResourceLoader.exists(p):
			return p
	return ""

func find_pixel_image(base_name: String) -> String:
	for ext: String in [".png", ".jpg", ".webp"]:
		var p: String = "res://assets/sprites/characters/" + base_name + ext
		if ResourceLoader.exists(p):
			return p
	return ""
