extends NodeState

@export var character: CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D
@export var wait_time: float = 3.0

var timer: float = 0.0

func _on_process(delta: float) -> void:
	timer += delta
	if timer >= wait_time:
		transition.emit("walk")

func _on_enter() -> void:
	timer = 0.0
	if animated_sprite_2d:
		animated_sprite_2d.play("idle" if animated_sprite_2d.sprite_frames.has_animation("idle") else "idle_front")

func _on_exit() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.stop()
