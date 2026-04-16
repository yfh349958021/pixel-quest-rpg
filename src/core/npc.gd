extends CharacterBody2D
## NPC角色

@export var npc_name: String = ""
@export var is_core_character: bool = false
@export var pixel_image_base: String = ""
@export var portrait_image_base: String = ""

signal dialogue_requested(npc: Node)

@onready var sprite: Sprite2D = $Sprite2D

var en_name: String = ""
var _name_label: Label = null
var _interact_hint: Label = null

func _ready() -> void:
	add_to_group("npcs")
	_extract_en_name()
	_load_sprite()
	_create_name_label()
	_create_interact_hint()
	GameManager.npc_status_changed.connect(_on_status_changed)

func _create_name_label() -> void:
	# 查找已有的NameLabel（map_manager创建的）
	_name_label = get_node_or_null("NameLabel")
	if not _name_label:
		_name_label = Label.new()
		_name_label.name = "NameLabel"
		add_child(_name_label)
	_name_label.text = npc_name
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.z_index = 10
	_name_label.add_theme_font_size_override("font_size", 14)
	_name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	# 文字描边效果（通过shadow）
	_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	_name_label.add_theme_constant_override("shadow_offset_x", 1)
	_name_label.add_theme_constant_override("shadow_offset_y", 1)

func _create_interact_hint() -> void:
	_interact_hint = Label.new()
	_interact_hint.name = "InteractHint"
	_interact_hint.text = "[空格] 交互"
	_interact_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interact_hint.z_index = 10
	_interact_hint.add_theme_font_size_override("font_size", 12)
	_interact_hint.add_theme_color_override("font_color", Color(1, 1, 0.5))
	_interact_hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	_interact_hint.add_theme_constant_override("shadow_offset_x", 1)
	_interact_hint.add_theme_constant_override("shadow_offset_y", 1)
	_interact_hint.visible = false
	add_child(_interact_hint)

func get_npc_name() -> String:
	return npc_name

func _extract_en_name() -> void:
	var file_path: String = "res://data/npc_dialogues/" + npc_name + "_talk_cn.txt"
	var full_path: String = file_path.replace("res://", ProjectSettings.globalize_path("res://"))
	if not FileAccess.file_exists(full_path):
		return
	var file: FileAccess = FileAccess.open(full_path, FileAccess.READ)
	if not file:
		return
	var first_line: String = file.get_line()
	file.close()
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
	if not sprite:
		return
	if pixel_image_base == "":
		return
	var status: String = GameManager.get_npc_status(npc_name)
	var image_name: String = pixel_image_base
	if status != "default" and status != "":
		image_name += "_" + status
	var path: String = LocalizationManager.find_pixel_image(image_name + "_0")
	if path == "":
		path = LocalizationManager.find_pixel_image(pixel_image_base + "_0")
	if path != "":
		var tex: Texture2D = _load_texture_from_path(path)
		if tex:
			sprite.texture = tex
	else:
		# 回退：彩色方块
		sprite.modulate = Color(0.8, 0.5, 0.9, 1) if is_core_character else Color(0.5, 0.5, 0.5, 1)

func _physics_process(_delta: float) -> void:
	# 更新标签位置（相对于角色上方）
	if _name_label:
		_name_label.position = Vector2(-30, -28)
	if _interact_hint:
		_interact_hint.position = Vector2(-30, -42)
		# 检查玩家距离决定是否显示交互提示
		var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
		if player and player.position.distance_to(position) < 60.0:
			_interact_hint.visible = true
		else:
			_interact_hint.visible = false

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

func _load_texture_from_path(path: String) -> Texture2D:
	var file_path: String = path.replace("res://", ProjectSettings.globalize_path("res://"))
	if not FileAccess.file_exists(file_path):
		return null
	var img := Image.load_from_file(file_path)
	if img == null:
		return null
	return ImageTexture.create_from_image(img)
