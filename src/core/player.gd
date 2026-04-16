extends CharacterBody2D
## 玩家角色控制器

const SPEED: float = 200.0
const SPRITE_SCALE: Vector2 = Vector2(2.0, 2.0)
const FRAME_SIZE: int = 32

@export var npc_name: String = ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var camera: Camera2D = $Camera2D

var _frozen: bool = true
var _direction: int = 0  # 0=下 1=左 2=右 3=上
var _anim_timer: float = 0.0
var _anim_frame: int = 0
var _is_moving: bool = false
var _nearby_npcs: Array = []
var _current_npc: Node2D = null
var _click_target: Vector2 = Vector2.ZERO  # 鼠标点击目标位置
var _has_click_target: bool = false

signal interact_requested(npc: Node2D)

func _ready() -> void:
	# 加载主角行走图
	var sprite_path: String = "res://assets/characters/player/walk.png"
	var tex: Texture2D = _load_texture_from_path(sprite_path)
	if tex:
		sprite.texture = tex
		sprite.hframes = 4
		sprite.vframes = 4
		sprite.frame_coords = Vector2i(0, 0)
		sprite.scale = SPRITE_SCALE
	else:
		sprite.scale = Vector2(1.5, 1.5)
	sprite.offset = Vector2(0, 8)
	interaction_area.body_entered.connect(_on_area_body_entered)
	interaction_area.body_exited.connect(_on_area_body_exited)
	_freeze(true)

func _physics_process(delta: float) -> void:
	if _frozen:
		return
	
	var input_dir := Vector2.ZERO
	
	# 键盘输入优先
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	
	# 如果有键盘输入，取消鼠标点击目标
	if input_dir.length() > 0.1:
		_has_click_target = false
	
	# 鼠标点击移动
	if _has_click_target:
		var to_target := _click_target - position
		var dist := to_target.length()
		if dist < 5.0:
			_has_click_target = false
			_is_moving = false
			velocity = Vector2.ZERO
			_anim_frame = 0
			sprite.frame_coords = Vector2i(0, _direction)
			move_and_slide()
			return
		input_dir = to_target.normalized()
	
	if input_dir.length() > 0.1:
		_is_moving = true
		input_dir = input_dir.normalized()
		velocity = input_dir * SPEED
		# 更新方向
		if input_dir.y > 0.3:
			_direction = 0  # 下
		elif input_dir.y < -0.3:
			_direction = 3  # 上
		elif input_dir.x < -0.3:
			_direction = 1  # 左
		elif input_dir.x > 0.3:
			_direction = 2  # 右
		# 行走动画
		_anim_timer += delta
		if _anim_timer >= 0.15:
			_anim_timer = 0.0
			_anim_frame = (_anim_frame + 1) % 4
		sprite.frame_coords = Vector2i(_anim_frame, _direction)
	else:
		_is_moving = false
		velocity = Vector2.ZERO
		_anim_frame = 0
		sprite.frame_coords = Vector2i(0, _direction)
	
	# 交互提示
	if Input.is_action_just_pressed("interact"):
		_try_interact()
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if _frozen:
		return
	# 鼠标左键点击移动
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 检查是否点击在UI上（是的话不处理）
		if event.position.y > get_viewport_rect().size.y - 250:
			return  # 点击在对话框区域，忽略
		_click_target = camera.get_global_mouse_position()
		_has_click_target = true

func _on_area_body_entered(body: Node2D) -> void:
	if body.name.begins_with("NPC_"):
		_nearby_npcs.append(body)
		_current_npc = body

func _on_area_body_exited(body: Node2D) -> void:
	if body in _nearby_npcs:
		_nearby_npcs.erase(body)
	if _current_npc == body:
		_current_npc = _nearby_npcs[-1] if _nearby_npcs.size() > 0 else null

func _try_interact() -> void:
	if _current_npc and is_instance_valid(_current_npc):
		interact_requested.emit(_current_npc)

func freeze_movement(freeze: bool) -> void:
	_frozen = freeze
	if freeze:
		velocity = Vector2.ZERO
		_has_click_target = false

func _load_texture_from_path(path: String) -> Texture2D:
	var file_path: String = path.replace("res://", ProjectSettings.globalize_path("res://"))
	if not FileAccess.file_exists(file_path):
		return null
	var img := Image.load_from_file(file_path)
	if img == null:
		return null
	return ImageTexture.create_from_image(img)

func get_save_position() -> Vector2:
	return position
