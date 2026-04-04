class_name HurtComponent
extends Area2D

@export var tool: DataTypes.Tools = DataTypes.Tools.None
signal hurt(damage: int)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("get_hit") and area.get("current_tool") == tool:
		hurt.emit(area.get("hit_damage") if area.get("hit_damage") else 1)
