extends CanvasLayer
## 回合制战斗系统

var main: Node
var enemy_id: String = ""
var is_boss: bool = false

var enemy: Dictionary = {}
var enemy_hp: int = 0
var player_buffs: Dictionary = {}
var enemy_buffs: Dictionary = {}
var phase: int = 0  # 0=等待 1=玩家回合 2=敌人回合 3=胜利 4=失败

var battle_log: RichTextLabel
var action_menu: VBoxContainer
var skill_menu: VBoxContainer
var item_menu: VBoxContainer

func _ready():
	enemy = main.EnemiesDB.get_random_encounter(main.game_data.current_map)
	if enemy_id != "":
		enemy = main.EnemiesDB.get_enemy(enemy_id)
	if enemy.is_empty():
		enemy = main.EnemiesDB.get_enemy("slime")
	enemy_hp = enemy.get("hp", 20)
	_build_ui()
	_log("=== 战斗开始 ===")
	_log("%s 出现了！" % enemy.get("name", "敌人"))
	phase = 1
	_show_actions()

func _build_ui():
	# 背景
	var bg_path = "res://assets/tilesets/battle_bg.png"
	if ResourceLoader.exists(bg_path):
		var bg_tex = TextureRect.new()
		bg_tex.texture = load(bg_path)
		bg_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg_tex.stretch_mode = TextureRect.STRETCH_SCALE
		add_child(bg_tex)
	else:
		var bg = ColorRect.new()
		bg.color = Color(0.1, 0.15, 0.2)
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(bg)
	
	# 敌人
	var enemy_sp = Sprite2D.new()
	enemy_sp.name = "EnemySprite"
	enemy_sp.position = Vector2(350, 140)
	var epath = "res://assets/sprites/%s.png" % enemy.get("sprite", "slime")
	if ResourceLoader.exists(epath):
		enemy_sp.texture = load(epath)
	enemy_sp.scale = Vector2(2, 2)
	add_child(enemy_sp)
	
	# 玩家
	var player_sp = Sprite2D.new()
	player_sp.position = Vector2(130, 180)
	var hpath = "res://assets/sprites/hero.png"
	if ResourceLoader.exists(hpath):
		player_sp.texture = load(hpath)
		player_sp.hframes = 4
		player_sp.frame = 2
	player_sp.scale = Vector2(2, 2)
	add_child(player_sp)
	
	# 敌人信息
	var enemy_panel = PanelContainer.new()
	enemy_panel.position = Vector2(280, 30)
	enemy_panel.size = Vector2(180, 50)
	var evbox = VBoxContainer.new()
	var ename = Label.new()
	ename.text = enemy.get("name", "敌人")
	evbox.add_child(ename)
	var ehp = ProgressBar.new()
	ehp.name = "EnemyHP"
	ehp.max_value = enemy.get("hp", 20)
	ehp.value = enemy_hp
	ehp.size = Vector2(160, 12)
	evbox.add_child(ehp)
	enemy_panel.add_child(evbox)
	add_child(enemy_panel)
	
	# 玩家信息
	var player_panel = PanelContainer.new()
	player_panel.position = Vector2(20, 240)
	player_panel.size = Vector2(180, 70)
	var pvbox = VBoxContainer.new()
	var pname = Label.new()
	pname.text = "%s Lv.%d" % [main.game_data.player_name, main.game_data.level]
	pvbox.add_child(pname)
	var php = ProgressBar.new()
	php.name = "PlayerHP"
	php.max_value = main.game_data.max_hp
	php.value = main.game_data.hp
	php.size = Vector2(160, 12)
	php.modulate = Color(0.8, 0.2, 0.2)
	pvbox.add_child(php)
	var pmp = ProgressBar.new()
	pmp.name = "PlayerMP"
	pmp.max_value = main.game_data.max_mp
	pmp.value = main.game_data.mp
	pmp.size = Vector2(160, 10)
	pmp.modulate = Color(0.2, 0.4, 0.9)
	pvbox.add_child(pmp)
	player_panel.add_child(pvbox)
	add_child(player_panel)
	
	# 战斗日志
	battle_log = RichTextLabel.new()
	battle_log.position = Vector2(210, 240)
	battle_log.size = Vector2(250, 70)
	battle_log.bbcode_enabled = true
	battle_log.scroll_active = true
	battle_log.scroll_following = true
	add_child(battle_log)
	
	# 行动菜单
	action_menu = VBoxContainer.new()
	action_menu.name = "ActionMenu"
	action_menu.position = Vector2(20, 140)
	action_menu.size = Vector2(100, 100)
	_add_action_button("攻击", _on_attack)
	_add_action_button("技能", _on_skill)
	_add_action_button("物品", _on_item)
	_add_action_button("防御", _on_defend)
	_add_action_button("逃跑", _on_run)
	add_child(action_menu)
	
	# 技能菜单
	skill_menu = VBoxContainer.new()
	skill_menu.name = "SkillMenu"
	skill_menu.position = Vector2(20, 100)
	skill_menu.visible = false
	add_child(skill_menu)
	
	# 物品菜单
	item_menu = VBoxContainer.new()
	item_menu.name = "ItemMenu"
	item_menu.position = Vector2(20, 100)
	item_menu.visible = false
	add_child(item_menu)

func _add_action_button(text: String, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.pressed.connect(callback)
	action_menu.add_child(btn)

func _log(msg: String):
	if battle_log:
		battle_log.text += msg + "\n"
		battle_log.scroll_to_line(battle_log.get_line_count())

func _update_ui():
	var php = get_node_or_null("PlayerHP")
	var pmp = get_node_or_null("PlayerMP")
	var ehp = get_node_or_null("EnemyHP")
	if php:
		php.value = main.game_data.hp
	if pmp:
		pmp.value = main.game_data.mp
	if ehp:
		ehp.value = enemy_hp

func _show_actions():
	action_menu.visible = true
	skill_menu.visible = false
	item_menu.visible = false

func _on_attack():
	if phase != 1:
		return
	phase = 2
	action_menu.visible = false
	
	# 计算伤害
	var dmg = main.game_data.get_atk() + player_buffs.get("atk", 0)
	dmg = max(1, dmg - enemy.get("def", 0) - enemy_buffs.get("def", 0))
	enemy_hp -= dmg
	_log("你攻击了%s！造成%d伤害！" % [enemy["name"], dmg])
	
	_update_ui()
	await get_tree().create_timer(0.5).timeout
	_check_end()

func _on_skill():
	if phase != 1:
		return
	
	action_menu.visible = false
	skill_menu.visible = true
	
	# 清空并重建
	for c in skill_menu.get_children():
		c.queue_free()
	
	var skills = main.SkillsDB.get_available(main.game_data.level)
	for sk in skills:
		var btn = Button.new()
		btn.text = "%s (%dMP)" % [sk["name"], sk.get("mp", 0)]
		if main.game_data.mp < sk.get("mp", 0):
			btn.disabled = true
		btn.pressed.connect(_use_skill.bind(sk["id"]))
		skill_menu.add_child(btn)
	
	var back = Button.new()
	back.text = "返回"
	back.pressed.connect(_show_actions)
	skill_menu.add_child(back)

func _use_skill(sid: String):
	phase = 2
	skill_menu.visible = false
	
	var sk = main.SkillsDB.get_skill(sid)
	if sk.is_empty():
		_log("技能无效！")
		_show_actions()
		phase = 1
		return
	
	var mp_cost = sk.get("mp", 0)
	if not main.game_data.use_mp(mp_cost):
		_log("MP不足！")
		_show_actions()
		phase = 1
		return
	
	var sk_type = sk.get("type", "attack")
	match sk_type:
		"attack":
			var power = sk.get("power", 1.0)
			var dmg = int((main.game_data.get_atk() + player_buffs.get("atk", 0)) * power)
			dmg = max(1, dmg - enemy.get("def", 0))
			enemy_hp -= dmg
			_log("使用%s！造成%d伤害！" % [sk["name"], dmg])
		"magic":
			var power = sk.get("power", 2.0)
			var dmg = int(main.game_data.get_atk() * power)
			enemy_hp -= dmg
			_log("使用%s！造成%d魔法伤害！" % [sk["name"], dmg])
		"heal":
			var val = sk.get("value", 30)
			main.game_data.heal(val)
			_log("使用%s！恢复%dHP！" % [sk["name"], val])
		"buff_self":
			var stat = sk.get("stat", "atk")
			var val = sk.get("value", 5)
			var turns = sk.get("turns", 3)
			player_buffs[stat] = player_buffs.get(stat, 0) + val
			_log("使用%s！%s+%d！" % [sk["name"], stat.to_upper(), val])
			# TODO: 处理临时buff
		_:
			_log("使用%s！" % sk["name"])
	
	_update_ui()
	await get_tree().create_timer(0.5).timeout
	_check_end()

func _on_item():
	if phase != 1:
		return
	
	action_menu.visible = false
	item_menu.visible = true
	
	for c in item_menu.get_children():
		c.queue_free()
	
	for item in main.game_data.inventory:
		var info = main.ItemsDB.get_item(item["id"])
		if info.get("type") != "consumable":
			continue
		var btn = Button.new()
		btn.text = "%s x%d" % [info.get("name", item["id"]), item.get("amount", 1)]
		btn.pressed.connect(_use_item.bind(item["id"]))
		item_menu.add_child(btn)
	
	var back = Button.new()
	back.text = "返回"
	back.pressed.connect(_show_actions)
	item_menu.add_child(back)

func _use_item(item_id: String):
	phase = 2
	item_menu.visible = false
	
	var info = main.ItemsDB.get_item(item_id)
	main.game_data.remove_item(item_id)
	
	match info.get("effect"):
		"heal":
			main.game_data.heal(info.get("value", 30))
			_log("使用%s！恢复%dHP！" % [info["name"], info.get("value", 30)])
		"mp":
			main.game_data.restore_mp(info.get("value", 20))
			_log("使用%s！恢复%dMP！" % [info["name"], info.get("value", 20)])
		_:
			_log("使用%s！" % info.get("name", item_id))
	
	_update_ui()
	await get_tree().create_timer(0.5).timeout
	_check_end()

func _on_defend():
	if phase != 1:
		return
	phase = 2
	action_menu.visible = false
	
	player_buffs["def"] = player_buffs.get("def", 0) + 5
	_log("进入防御姿态！DEF+5")
	
	await get_tree().create_timer(0.5).timeout
	_enemy_turn()

func _on_run():
	if phase != 1:
		return
	
	if enemy.get("is_boss", false):
		_log("无法从Boss战逃跑！")
		return
	
	var chance = 0.5 + (main.game_data.get_spd() - enemy.get("spd", 5)) * 0.03
	if randf() < chance:
		_log("成功逃跑！")
		await get_tree().create_timer(0.5).timeout
		main._enter_world_after_battle()
	else:
		_log("逃跑失败！")
		phase = 2
		action_menu.visible = false
		await get_tree().create_timer(0.5).timeout
		_enemy_turn()

func _check_end():
	if enemy_hp <= 0:
		_on_victory()
	elif main.game_data.hp <= 0:
		_on_defeat()
	else:
		_enemy_turn()

func _enemy_turn():
	phase = 2
	
	# 选择技能
	var skills = enemy.get("skills", [{"name":"攻击","type":"attack","power":1.0}])
	var sk = skills[randi() % skills.size()]
	
	await get_tree().create_timer(0.3).timeout
	
	var sk_type = sk.get("type", "attack")
	match sk_type:
		"attack":
			var power = sk.get("power", 1.0)
			var dmg = int((enemy.get("atk", 10) + enemy_buffs.get("atk", 0)) * power)
			dmg = max(1, dmg - main.game_data.get_def() - player_buffs.get("def", 0))
			main.game_data.take_damage(dmg)
			_log("%s使用%s！造成%d伤害！" % [enemy["name"], sk["name"], dmg])
		"drain":
			var power = sk.get("power", 0.8)
			var drain_pct = sk.get("drain_pct", 0.5)
			var dmg = int((enemy.get("atk", 10) + enemy_buffs.get("atk", 0)) * power)
			dmg = max(1, dmg - main.game_data.get_def())
			main.game_data.take_damage(dmg)
			var heal_amt = int(dmg * drain_pct)
			enemy_hp = min(enemy.get("hp", 20), enemy_hp + heal_amt)
			_log("%s使用%s！造成%d伤害并恢复%dHP！" % [enemy["name"], sk["name"], dmg, heal_amt])
		"heal_self":
			var val = sk.get("value", 15)
			enemy_hp = min(enemy.get("hp", 20), enemy_hp + val)
			_log("%s恢复%dHP！" % [enemy["name"], val])
		"buff_self":
			var stat = sk.get("stat", "atk")
			var val = sk.get("value", 3)
			enemy_buffs[stat] = enemy_buffs.get(stat, 0) + val
			_log("%s的%s提升了%d！" % [enemy["name"], stat.to_upper(), val])
		"debuff_player":
			var stat = sk.get("stat", "def")
			var val = sk.get("value", 3)
			player_buffs[stat] = player_buffs.get(stat, 0) - val
			_log("%s的%s降低了%d！" % [enemy["name"], stat.to_upper(), val])
		_:
			_log("%s使用%s！" % [enemy["name"], sk.get("name", "攻击")])
	
	_update_ui()
	
	if main.game_data.hp <= 0:
		_on_defeat()
		return
	
	# 清理buff
	for stat in player_buffs.keys():
		player_buffs[stat] = 0  # 简化处理，每回合重置
	
	phase = 1
	_show_actions()

func _on_victory():
	phase = 3
	action_menu.visible = false
	
	_log("=== 胜利！===")
	
	var exp_gain = enemy.get("exp", 10)
	var gold_gain = enemy.get("gold", 10)
	_log("获得%d经验，%d金币！" % [exp_gain, gold_gain])
	
	var leveled = main.game_data.add_exp(exp_gain)
	if leveled:
		_log("升级了！现在是Lv.%d！" % main.game_data.level)
	
	main.game_data.gold += gold_gain
	
	# 掉落
	var drops = enemy.get("drops", [])
	for drop in drops:
		if randf() < drop.get("chance", 0.1):
			var item_id = drop.get("id", "")
			if main.game_data.add_item(item_id):
				var iname = main.ItemsDB.get_item(item_id).get("name", item_id)
				_log("获得了%s！" % iname)
	
	# Boss记录
	if enemy.get("is_boss", false):
		main.game_data.defeated_enemies.append(enemy.get("id", ""))
		_log("击败了%s！" % enemy["name"])
	
	_update_ui()
	
	await get_tree().create_timer(2.0).timeout
	main._enter_world_after_battle()

func _on_defeat():
	phase = 4
	action_menu.visible = false
	
	_log("=== 战败 ===")
	_log("勇者倒下了...")
	
	await get_tree().create_timer(2.0).timeout
	
	# 惩罚
	main.game_data.hp = main.game_data.max_hp / 2
	main.game_data.mp = main.game_data.max_mp / 2
	main.game_data.gold = maxi(0, main.game_data.gold / 2)
	main.game_data.current_map = "town"
	main.game_data.player_pos = Vector2i(10, 8)
	
	main._enter_world_after_battle()
