extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

func _on_physics_process(_delta: float) -> void:
	GameInputEvents.movement_input()
	if GameInputEvents.is_movement_input():
		transition.emit("walk")
	elif GameInputEvents.use_tool() and player.current_tool != DataTypes.Tools.None:
		match player.current_tool:
			DataTypes.Tools.AxeWood, DataTypes.Tools.Hoe, DataTypes.Tools.Pickaxe:
				transition.emit("chopping")
			DataTypes.Tools.TillGround:
				transition.emit("tilling")
			DataTypes.Tools.WaterCrops:
				transition.emit("watering")

func _on_enter() -> void:
	if animated_sprite_2d and animated_sprite_2d.sprite_frames:
		var dir = _get_dir_name()
		if animated_sprite_2d.sprite_frames.has_animation("idle_" + dir):
			animated_sprite_2d.play("idle_" + dir)
		else:
			animated_sprite_2d.play("idle_front")

func _get_dir_name() -> String:
	if player.player_direction == Vector2.UP: return "back"
	if player.player_direction == Vector2.DOWN: return "front"
	if player.player_direction == Vector2.LEFT: return "left"
	if player.player_direction == Vector2.RIGHT: return "right"
	return "front"

func _on_exit() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.stop()
