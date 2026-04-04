extends Sprite2D

@export var max_hp: int = 3
var current_hp: int = 3
var hurt_component: HurtComponent
var shake_time: float = 0.0

func _ready() -> void:
	hurt_component = get_node_or_null("HurtComponent")
	if hurt_component:
		hurt_component.hurt.connect(_on_hurt)

func _on_hurt(damage: int) -> void:
	current_hp -= damage
	shake_time = 0.3
	if current_hp <= 0:
		InventoryManager.add_collectable("stone", 2)
		queue_free()

func _process(delta: float) -> void:
	if shake_time > 0:
		shake_time -= delta
		offset.x = randf_range(-2, 2)
		offset.y = randf_range(-1, 1)
	else:
		offset = Vector2.ZERO
