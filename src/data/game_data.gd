extends Node
signal stats_changed

var player_name: String = "勇者"
var level: int = 1
var exp: int = 0
var gold: int = 100
var max_hp: int = 50
var hp: int = 50
var max_mp: int = 20
var mp: int = 20
var base_atk: int = 10
var base_def: int = 5
var base_spd: int = 8
var weapon: Dictionary = {}
var armor: Dictionary = {}
var accessory: Dictionary = {}
var inventory: Array = []
var max_inventory: int = 20
var current_map: String = "town"
var player_pos: Vector2i = Vector2i(10, 8)
var switches: Dictionary = {}
var variables: Dictionary = {}
var defeated_enemies: Array = []
var opened_chests: Array = []
const SAVE_DIR = "user://saves/"

func _ready():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func get_atk() -> int:
	return base_atk + weapon.get("atk", 0) + accessory.get("atk", 0)

func get_def() -> int:
	return base_def + armor.get("def", 0) + accessory.get("def", 0)

func get_spd() -> int:
	return base_spd + accessory.get("spd", 0)

func exp_for_level(lv: int) -> int:
	return int(30 * pow(lv, 1.5))

func exp_needed() -> int:
	return exp_for_level(level)

func add_exp(amount: int) -> bool:
	exp += amount
	var leveled = false
	while exp >= exp_needed():
		exp -= exp_needed()
		level += 1
		max_hp += 5 + randi() % 4
		max_mp += 2 + randi() % 2
		base_atk += 2 + randi() % 2
		base_def += 1 + randi() % 2
		base_spd += 1
		hp = max_hp
		mp = max_mp
		leveled = true
	stats_changed.emit()
	return leveled

func add_item(item_id: String, amount: int = 1) -> bool:
	var stackable = false
	if item_id.begins_with("potion") or item_id.begins_with("antidote") or item_id == "phoenix" or item_id == "tent":
		stackable = true
	if stackable:
		for i in inventory.size():
			if inventory[i]["id"] == item_id:
				inventory[i]["amount"] += amount
				return true
	if inventory.size() >= max_inventory:
		return false
	inventory.append({"id": item_id, "amount": amount})
	return true

func remove_item(item_id: String, amount: int = 1) -> bool:
	for i in inventory.size():
		if inventory[i]["id"] == item_id:
			inventory[i]["amount"] -= amount
			if inventory[i]["amount"] <= 0:
				inventory.remove_at(i)
			return true
	return false

func has_item(item_id: String) -> bool:
	for item in inventory:
		if item["id"] == item_id:
			return true
	return false

func take_damage(dmg: int) -> int:
	var actual = max(1, dmg - get_def())
	hp = max(0, hp - actual)
	stats_changed.emit()
	return actual

func heal(amount: int):
	hp = min(max_hp, hp + amount)
	stats_changed.emit()

func use_mp(cost: int) -> bool:
	if mp >= cost:
		mp -= cost
		stats_changed.emit()
		return true
	return false

func restore_mp(amount: int):
	mp = min(max_mp, mp + amount)

func save_game(slot: int = 1) -> bool:
	var data = {
		"player_name": player_name, "level": level, "exp": exp, "gold": gold,
		"max_hp": max_hp, "hp": hp, "max_mp": max_mp, "mp": mp,
		"base_atk": base_atk, "base_def": base_def, "base_spd": base_spd,
		"weapon": weapon, "armor": armor, "accessory": accessory,
		"inventory": inventory, "current_map": current_map,
		"player_pos": {"x": player_pos.x, "y": player_pos.y},
		"switches": switches, "variables": variables,
		"defeated_enemies": defeated_enemies, "opened_chests": opened_chests,
	}
	var path = SAVE_DIR + "save_%d.json" % slot
	var f = FileAccess.open(path, FileAccess.WRITE)
	if not f:
		return false
	f.store_string(JSON.stringify(data, "\t"))
	return true

func load_game(slot: int = 1) -> bool:
	var path = SAVE_DIR + "save_%d.json" % slot
	if not FileAccess.file_exists(path):
		return false
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		return false
	var data = JSON.parse_string(f.get_as_text())
	if not data:
		return false
	player_name = data.get("player_name", "勇者")
	level = data.get("level", 1)
	exp = data.get("exp", 0)
	gold = data.get("gold", 0)
	max_hp = data.get("max_hp", 50)
	hp = data.get("hp", max_hp)
	max_mp = data.get("max_mp", 20)
	mp = data.get("mp", max_mp)
	base_atk = data.get("base_atk", 10)
	base_def = data.get("base_def", 5)
	base_spd = data.get("base_spd", 8)
	weapon = data.get("weapon", {})
	armor = data.get("armor", {})
	accessory = data.get("accessory", {})
	inventory = data.get("inventory", [])
	current_map = data.get("current_map", "town")
	var pos = data.get("player_pos", {"x": 10, "y": 8})
	player_pos = Vector2i(int(pos.get("x", 10)), int(pos.get("y", 8)))
	switches = data.get("switches", {})
	variables = data.get("variables", {})
	defeated_enemies = data.get("defeated_enemies", [])
	opened_chests = data.get("opened_chests", [])
	stats_changed.emit()
	return true

func has_save(slot: int = 1) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "save_%d.json" % slot)

func new_game():
	player_name = "勇者"
	level = 1
	exp = 0
	gold = 100
	max_hp = 50
	hp = 50
	max_mp = 20
	mp = 20
	base_atk = 10
	base_def = 5
	base_spd = 8
	weapon = {}
	armor = {}
	accessory = {}
	inventory = [
		{"id": "potion_hp", "amount": 3},
		{"id": "potion_mp", "amount": 2},
	]
	current_map = "town"
	player_pos = Vector2i(10, 8)
	switches = {}
	variables = {}
	defeated_enemies = []
	opened_chests = []
	stats_changed.emit()
