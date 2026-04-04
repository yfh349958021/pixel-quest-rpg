extends Node

var inventory: Dictionary = {}
signal inventory_changed

func add_collectable(name: String, amount: int = 1) -> void:
	if inventory.has(name):
		inventory[name] += amount
	else:
		inventory[name] = amount
	inventory_changed.emit()

func remove_collectable(name: String, amount: int = 1) -> bool:
	if not inventory.has(name) or inventory[name] < amount:
		return false
	inventory[name] -= amount
	if inventory[name] <= 0:
		inventory.erase(name)
	inventory_changed.emit()
	return true

func get_count(name: String) -> int:
	return inventory.get(name, 0)
