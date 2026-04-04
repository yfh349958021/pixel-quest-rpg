extends NodeState

@export var character: CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D
@export var walk_speed: float = 20.0
@export var walk_range: float = 60.0

var start_pos: Vector2
var target_pos: Vector2
var timer: float = 0.0
var max_walk_time: float = 3.0

func _on_enter() -> void:
	start_pos = character.global_position
	var angle = randf() * TAU
	target_pos = start_pos + Vector2(cos(angle), sin(angle)) * walk_range
	timer = 0.0
	if animated_sprite_2d:
		animated_sprite_2d.play("walk" if animated_sprite_2d.sprite_frames.has_animation("walk") else "walk_front")

func _on_physics_process(delta: float) -> void:
	timer += delta
	if timer > max_walk_time or character.global_position.distance_to(target_pos) < 5:
		character.velocity = Vector2.ZERO
		transition.emit("idle")
		return
	
	var dir = character.global_position.direction_to(target_pos)
	character.velocity = dir * walk_speed
	character.move_and_slide()
	
	if animated_sprite_2d:
		animated_sprite_2d.flip_h = dir.x < 0

func _on_exit() -> void:
	character.velocity = Vector2.ZERO
	if animated_sprite_2d:
		animated_sprite_2d.stop()
