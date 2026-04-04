extends Node2D

@export var crop_type: String = "corn"
@export var days_to_grow: int = 3
var growth_state: int = 0
var is_watered: bool = false
var days_watered: int = 0
var sprite: Sprite2D

func _ready() -> void:
	sprite = get_node_or_null("Sprite2D")
	DayAndNightCycleManager.time_tick_day.connect(_on_new_day)
	_update_sprite()

func _on_new_day(day: int) -> void:
	if is_watered:
		days_watered += 1
		is_watered = false
		if days_watered >= days_to_grow:
			growth_state = 5  # Harvestable
		else:
			growth_state = min(days_watered + 1, 4)
		_update_sprite()

func water() -> void:
	is_watered = true

func harvest() -> bool:
	if growth_state < 5:
		return false
	InventoryManager.add_collectable(crop_type, 1)
	queue_free()
	return true

func _update_sprite() -> void:
	if sprite and sprite.texture:
		var h_frames = sprite.hframes if sprite.hframes > 1 else 6
		sprite.frame = min(growth_state, h_frames - 1)
