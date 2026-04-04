extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

func _on_physics_process(_delta: float) -> void:
	var direction = GameInputEvents.movement_input()
	
	if animated_sprite_2d and animated_sprite_2d.sprite_frames:
		var dir_name = "front"
		if direction == Vector2.UP: dir_name = "back"
		elif direction == Vector2.DOWN: dir_name = "front"
		elif direction == Vector2.LEFT: dir_name = "left"
		elif direction == Vector2.RIGHT: dir_name = "right"
		
		var anim = "walk_" + dir_name
		if animated_sprite_2d.sprite_frames.has_animation(anim):
			animated_sprite_2d.play(anim)
		else:
			animated_sprite_2d.play("walk_front")
	
	if direction != Vector2.ZERO:
		player.player_direction = direction
	
	player.velocity = direction * player.speed
	player.move_and_slide()
	
	if not GameInputEvents.is_movement_input():
		transition.emit("idle")

func _on_exit() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.stop()
