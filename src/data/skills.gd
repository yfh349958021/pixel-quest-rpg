

const SKILLS = {
	"power_strike": {"id":"power_strike","name":"强力打击","type":"attack","mp":3,"power":1.8,"lv":1,"desc":"倍率180%"},
	"heal": {"id":"heal","name":"治疗","type":"heal","mp":5,"value":40,"lv":2,"desc":"恢复40HP"},
	"slash": {"id":"slash","name":"横扫","type":"attack","mp":5,"power":1.3,"lv":3,"desc":"倍率130%"},
	"iron_wall": {"id":"iron_wall","name":"铁壁","type":"buff_self","mp":4,"stat":"def","value":10,"turns":3,"lv":4,"desc":"DEF+10"},
	"charge": {"id":"charge","name":"冲锋","type":"attack","mp":4,"power":2.0,"lv":5,"desc":"倍率200%"},
	"fireball": {"id":"fireball","name":"火球术","type":"magic","mp":8,"power":2.5,"lv":6,"desc":"魔法倍率250%"},
	"war_cry": {"id":"war_cry","name":"战吼","type":"buff_self","mp":4,"stat":"atk","value":8,"turns":3,"lv":7,"desc":"ATK+8"},
	"heal_l": {"id":"heal_l","name":"大治疗","type":"heal","mp":12,"value":100,"lv":8,"desc":"恢复100HP"},
	"thunder": {"id":"thunder","name":"雷电","type":"magic","mp":10,"power":3.0,"lv":9,"desc":"魔法倍率300%"},
	"berserk": {"id":"berserk","name":"狂暴","type":"buff_self","mp":8,"stat":"atk","value":15,"stat2":"def","val2":-5,"turns":3,"lv":10,"desc":"ATK+15 DEF-5"},
}

static func get_skill(id: String) -> Dictionary:
	return SKILLS.get(id, {})

static func get_available(player_lv: int) -> Array:
	var r = []
	for sid in SKILLS:
		if SKILLS[sid]["lv"] <= player_lv:
			r.append(SKILLS[sid].duplicate(true))
	return r
