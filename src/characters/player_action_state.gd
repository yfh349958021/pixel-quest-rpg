extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var state_name: String = "chopping"
var action_timer: float = 0.0

func _on_process(delta: float) -> void:
	action_timer += delta
	if action_timer >= 0.5:
		transition.emit("idle")

func _on_enter() -> void:
	action_timer = 0.0
	player.velocity = Vector2.ZERO
	if animated_sprite_2d and animated_sprite_2d.sprite_frames:
		var dir = "front"
		if player.player_direction == Vector2.UP: dir = "back"
		elif player.player_direction == Vector2.LEFT: dir = "left"
		elif player.player_direction == Vector2.RIGHT: dir = "right"
		var anim = state_name + "_" + dir
		if not animated_sprite_2d.sprite_frames.has_animation(anim):
			anim = state_name + "_front"
		if not animated_sprite_2d.sprite_frames.has_animation(anim):
			anim = state_name
		animated_sprite_2d.play(anim)

func _on_exit() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.stop()
