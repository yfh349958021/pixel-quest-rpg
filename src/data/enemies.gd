

const ENEMIES = {
	"slime": {
		"id":"slime","name":"史莱姆","sprite":"slime",
		"hp":20,"atk":6,"def":2,"spd":3,"exp":8,"gold":5,
		"skills":[{"name":"撞击","type":"attack","power":1.0}],
		"drops":[{"id":"potion_hp","chance":0.3}]
	},
	"bat": {
		"id":"bat","name":"蝙蝠","sprite":"bat",
		"hp":15,"atk":8,"def":1,"spd":10,"exp":10,"gold":8,
		"skills":[
			{"name":"吸血","type":"drain","power":0.8,"drain_pct":0.5},
			{"name":"超声波","type":"attack","power":1.2}
		],
		"drops":[{"id":"potion_mp","chance":0.2}]
	},
	"goblin": {
		"id":"goblin","name":"哥布林","sprite":"goblin",
		"hp":30,"atk":10,"def":4,"spd":6,"exp":15,"gold":15,
		"skills":[
			{"name":"石斧","type":"attack","power":1.2},
			{"name":"叫帮手","type":"buff_self","stat":"atk","value":3,"turns":3}
		],
		"drops":[{"id":"leather_armor","chance":0.1}]
	},
	"wolf": {
		"id":"wolf","name":"森林狼","sprite":"slime",
		"hp":35,"atk":14,"def":5,"spd":9,"exp":22,"gold":18,
		"skills":[
			{"name":"利爪","type":"attack","power":1.3},
			{"name":"嚎叫","type":"buff_self","stat":"atk","value":5,"turns":2}
		],
		"drops":[{"id":"power_ring","chance":0.05}]
	},
	"treant": {
		"id":"treant","name":"树精","sprite":"slime",
		"hp":60,"atk":8,"def":12,"spd":2,"exp":25,"gold":20,
		"skills":[
			{"name":"树枝","type":"attack","power":1.0},
			{"name":"恢复","type":"heal_self","value":15}
		],
		"drops":[{"id":"potion_hp_l","chance":0.2}]
	},
	"skeleton": {
		"id":"skeleton","name":"骷髅兵","sprite":"skeleton",
		"hp":45,"atk":16,"def":8,"spd":7,"exp":30,"gold":25,
		"skills":[
			{"name":"骨剑","type":"attack","power":1.4},
			{"name":"骨盾","type":"buff_self","stat":"def","value":5,"turns":3}
		],
		"drops":[{"id":"steel_sword","chance":0.08}]
	},
	"ghost": {
		"id":"ghost","name":"幽灵","sprite":"ghost",
		"hp":40,"atk":18,"def":3,"spd":12,"exp":28,"gold":22,
		"skills":[
			{"name":"灵魂侵蚀","type":"attack","power":1.5},
			{"name":"诅咒","type":"debuff_player","stat":"def","value":3,"turns":3}
		],
		"drops":[{"id":"potion_mp","chance":0.3}]
	},
	"boss_goblin_king": {
		"id":"boss_goblin_king","name":"哥布林王","sprite":"boss",
		"hp":150,"atk":20,"def":10,"spd":8,"exp":100,"gold":200,"is_boss":true,
		"skills":[
			{"name":"王之铁锤","type":"attack","power":2.0},
			{"name":"召集部下","type":"buff_self","stat":"atk","value":8,"turns":3},
			{"name":"横扫","type":"attack","power":1.5}
		],
		"drops":[{"id":"iron_sword","chance":1.0},{"id":"hero_charm","chance":0.5}]
	},
	"boss_dragon": {
		"id":"boss_dragon","name":"暗黑龙","sprite":"boss",
		"hp":300,"atk":30,"def":15,"spd":10,"exp":300,"gold":500,"is_boss":true,
		"skills":[
			{"name":"龙息","type":"attack","power":2.5},
			{"name":"利爪","type":"attack","power":1.8},
			{"name":"尾巴横扫","type":"attack","power":1.5},
			{"name":"黑暗吐息","type":"debuff_player","stat":"def","value":8,"turns":3}
		],
		"drops":[{"id":"legend_sword","chance":1.0}]
	},
}

const ENCOUNTER_TABLES = {
	"town": [],
	"grassland": ["slime","slime","bat","goblin"],
	"forest": ["wolf","wolf","treant","bat","goblin"],
	"cave": ["skeleton","skeleton","ghost","bat"],
	"castle": ["skeleton","ghost","skeleton","ghost"],
}

static func get_enemy(id: String) -> Dictionary:
	return ENEMIES.get(id, {})

static func get_random_encounter(map_id: String) -> Dictionary:
	var table = ENCOUNTER_TABLES.get(map_id, [])
	if table.is_empty():
		return {}
	var eid = table[randi() % table.size()]
	return ENEMIES.get(eid, {})
