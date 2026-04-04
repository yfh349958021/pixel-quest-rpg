class_name DamageComponent
extends Node2D

@export var max_damage: int = 1
var current_damage: int = 0
signal max_damaged_reached

func apply_damage(damage: int) -> void:
	current_damage = min(current_damage + damage, max_damage)
	if current_damage >= max_damage:
		max_damaged_reached.emit()

func reset() -> void:
	current_damage = 0
