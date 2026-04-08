extends Node
## 本地化管理器 - 文字和音频国际化

# 文字翻译表
var _text_table: Dictionary = {}

func _ready() -> void:
	load_translations()

func load_translations() -> void:
	_text_table.clear()
	# 加载翻译CSV文件
	var translation_files: Array = [
		"res://data/i18n_cn.csv",
		"res://data/i18n_jp.csv"
	]
	for path: String in translation_files:
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
			continue  # 跳过标题行
		
		var parts: PackedStringArray = line.split(",")
		if parts.size() >= 3:
			var key: String = parts[0].strip_edges()
			var cn: String = parts[1].strip_edges()
			var jp: String = parts[2].strip_edges()
			_text_table[key] = {"cn": cn, "jp": jp}
	file.close()

func get_text(key: String) -> String:
	if _text_table.has(key):
		match SettingsManager.current_language:
			SettingsManager.Language.CN:
				return _text_table[key]["cn"]
			SettingsManager.Language.JP:
				return _text_table[key]["jp"]
	return key  # 找不到翻译就返回key本身

## 查找音频文件，支持语言回退
func find_audio(base_name: String) -> String:
	var suffixes: Array = [SettingsManager.get_language_suffix()]
	# 添加回退后缀
	if suffixes[0] == "_cn":
		suffixes.append("_jp")
	else:
		suffixes.append("_cn")
	
	var extensions: Array = [".ogg", ".mp3", ".wav"]
	
	for suffix: String in suffixes:
		for ext: String in extensions:
			var path: String = "res://assets/audio/dialogue/" + base_name + suffix + ext
			if ResourceLoader.exists(path):
				return path
	return ""

## 查找角色图片，支持多格式回退
func find_portrait(base_name: String) -> String:
	var extensions: Array = [".png", ".jpg", ".gif", ".webp"]
	for ext: String in extensions:
		var path: String = "res://assets/sprites/portraits/" + base_name + ext
		if ResourceLoader.exists(path):
			return path
	return ""

## 查找像素图
func find_pixel_image(base_name: String) -> String:
	var extensions: Array = [".png", ".jpg", ".gif", ".webp"]
	for ext: String in extensions:
		var path: String = "res://assets/sprites/characters/" + base_name + ext
		if ResourceLoader.exists(path):
			return path
	return ""
