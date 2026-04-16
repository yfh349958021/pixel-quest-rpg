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

signal interact_requested(npc: Node2D)

func _ready() -> void:
	# 加载主角行走图
	var sprite_path: String = "res://assets/characters/player/walk.png"
	if ResourceLoader.exists(sprite_path):
		sprite.texture = load(sprite_path)
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
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	
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

func get_save_position() -> Vector2:
	return position
