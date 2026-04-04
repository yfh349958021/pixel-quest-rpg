

const ITEMS = {
	"potion_hp": {"id":"potion_hp","name":"生命药水","type":"consumable","stackable":true,"price":30,"effect":"heal","value":30,"desc":"恢复30HP"},
	"potion_hp_l": {"id":"potion_hp_l","name":"大生命药水","type":"consumable","stackable":true,"price":80,"effect":"heal","value":80,"desc":"恢复80HP"},
	"potion_mp": {"id":"potion_mp","name":"魔力药水","type":"consumable","stackable":true,"price":25,"effect":"mp","value":20,"desc":"恢复20MP"},
	"antidote": {"id":"antidote","name":"解毒草","type":"consumable","stackable":true,"price":15,"effect":"cure","desc":"解除中毒"},
	"phoenix": {"id":"phoenix","name":"凤凰尾","type":"consumable","stackable":true,"price":200,"effect":"revive","value":0.5,"desc":"复活并恢复50%HP"},
	"tent": {"id":"tent","name":"帐篷","type":"consumable","stackable":true,"price":100,"effect":"full_rest","desc":"完全恢复"},
	"iron_sword": {"id":"iron_sword","name":"铁剑","type":"weapon","price":200,"atk":8,"desc":"ATK+8"},
	"steel_sword": {"id":"steel_sword","name":"钢剑","type":"weapon","price":500,"atk":15,"desc":"ATK+15"},
	"magic_blade": {"id":"magic_blade","name":"魔剑","type":"weapon","price":1200,"atk":25,"desc":"ATK+25"},
	"legend_sword": {"id":"legend_sword","name":"传说之剑","type":"weapon","price":0,"atk":40,"desc":"ATK+40"},
	"leather_armor": {"id":"leather_armor","name":"皮甲","type":"armor","price":150,"def":5,"desc":"DEF+5"},
	"chain_mail": {"id":"chain_mail","name":"锁子甲","type":"armor","price":400,"def":10,"desc":"DEF+10"},
	"plate_armor": {"id":"plate_armor","name":"板甲","type":"armor","price":900,"def":18,"desc":"DEF+18"},
	"power_ring": {"id":"power_ring","name":"力量戒指","type":"accessory","price":300,"atk":5,"desc":"ATK+5"},
	"guard_ring": {"id":"guard_ring","name":"守护戒指","type":"accessory","price":300,"def":5,"desc":"DEF+5"},
	"speed_boots": {"id":"speed_boots","name":"疾风靴","type":"accessory","price":350,"spd":5,"desc":"SPD+5"},
	"hero_charm": {"id":"hero_charm","name":"勇者护符","type":"accessory","price":0,"atk":10,"def":10,"desc":"ATK+10 DEF+10"},
	"old_key": {"id":"old_key","name":"旧钥匙","type":"key","price":0,"desc":"打开古老的门"},
	"magic_gem": {"id":"magic_gem","name":"魔法宝石","type":"key","price":0,"desc":"散发神秘光芒"},
}

static func get_item(id: String) -> Dictionary:
	return ITEMS.get(id, {})
