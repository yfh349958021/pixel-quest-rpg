extends CharacterBody2D
## NPC角色

@export var npc_name: String = "npc"  # 中文名, 同时也是对话文件名
@export var is_core_character: bool = false
@export var pixel_image_base: String = ""  # 像素图基础名(en名)
@export var portrait_image_base: String = ""  # 立绘基础名(en名)

signal dialogue_requested(npc: Node)

@onready var sprite: Sprite2D = $Sprite2D

## 从对话文件中提取en名(第一行的key)
var en_name: String = ""

func _ready() -> void:
	_load_sprite()
	_extract_en_name()
	GameManager.npc_status_changed.connect(_on_status_changed)

func get_npc_name() -> String:
	return npc_name

func _extract_en_name() -> void:
	var file_path: String = "res://data/npc_dialogues/" + npc_name + "_talk_cn.txt"
	if not ResourceLoader.exists(file_path):
		return
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	var first_line: String = file.get_line()
	file.close()
	# 格式: {"en_name":"中文名","actor":"林远",...}
	var pattern: RegEx = RegEx.new()
	pattern.compile("\"([a-zA-Z_0-9]+)\":\"[^\"]+\"")
	var m: RegExMatch = pattern.search(first_line)
	if m:
		en_name = m.get_string(1)
		if pixel_image_base == "":
			pixel_image_base = en_name + "_pixelimage"
		if portrait_image_base == "":
			portrait_image_base = en_name + "_bigimage"

func _load_sprite() -> void:
	if pixel_image_base == "":
		return
	var status: String = GameManager.get_npc_status(npc_name)
	var image_name: String = pixel_image_base
	if status != "default" and status != "":
		image_name += "_" + status
	var path: String = LocalizationManager.find_pixel_image(image_name + "_0")
	if path == "":
		path = LocalizationManager.find_pixel_image(pixel_image_base + "_0")
	if path != "" and sprite:
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			sprite.texture = tex

func _on_status_changed(changed_npc: String, _status: String) -> void:
	if changed_npc == npc_name:
		_load_sprite()

func interact() -> void:
	dialogue_requested.emit(self)

func get_portrait_path() -> String:
	if not is_core_character:
		return ""
	if portrait_image_base == "":
		return ""
	return LocalizationManager.find_portrait(portrait_image_base + "_0")
