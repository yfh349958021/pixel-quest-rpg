extends CharacterBody2D
## 玩家角色

signal interact_with_npc(npc: Node)

@export var move_speed: float = 200.0

var _target_position: Vector2 = Vector2.ZERO
var _is_moving_to_target: bool = false

func _ready() -> void:
	position = GameManager.player_position

func _physics_process(_delta: float) -> void:
	if DialogueManager.is_active:
		velocity = Vector2.ZERO
		return
	
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		_is_moving_to_target = false
		velocity = input_dir.normalized() * move_speed
	elif _is_moving_to_target:
		var dir := (_target_position - position)
		var dist := dir.length()
		if dist < 5.0:
			_is_moving_to_target = false
			velocity = Vector2.ZERO
		else:
			velocity = dir.normalized() * move_speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	GameManager.player_position = position

func _input(event: InputEvent) -> void:
	if DialogueManager.is_active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_target_position = get_global_mouse_position()
		_is_moving_to_target = true
	if event.is_action_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	var areas := $InteractionArea.get_overlapping_areas()
	for area in areas:
		var parent := area.get_parent()
		if parent.has_method("get_npc_name"):
			interact_with_npc.emit(parent)
			return
