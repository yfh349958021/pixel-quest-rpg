extends CharacterBody2D
## NPC角色

@export var npc_name: String = "npc"
@export var is_core_character: bool = false  # 是否为核心角色（显示大立绘）
@export var pixel_image_base: String = ""  # 像素图基础名称
@export var portrait_image_base: String = ""  # 立绘基础名称

signal dialogue_requested(npc: Node)

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_load_sprite()
	GameManager.npc_status_changed.connect(_on_status_changed)

func get_npc_name() -> String:
	return npc_name

func _load_sprite() -> void:
	if pixel_image_base == "":
		pixel_image_base = npc_name + "_pixelimage"
	
	var status := GameManager.get_npc_status(npc_name)
	var image_name := pixel_image_base
	
	if status != "default" and status != "":
		image_name += "_" + status
	
	# 尝试加载图片
	var path := LocalizationManager.find_pixel_image(image_name + "_0")
	if path == "":
		path = LocalizationManager.find_pixel_image(pixel_image_base + "_0")
	
	if path != "" and sprite:
		var tex := load(path) as Texture2D
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
	
	var base := portrait_image_base if portrait_image_base != "" else npc_name + "_bigimage"
	var status := GameManager.get_npc_status(npc_name)
	
	# 尝试带状态的
	if status != "default" and status != "":
		var path := LocalizationManager.find_portrait(base + "_" + status + "_0")
		if path != "":
			return path
	
	# 回退到默认
	return LocalizationManager.find_portrait(base + "_0")
