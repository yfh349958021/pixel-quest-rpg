extends Node2D
## 世界探索画面 - 瓦片地图、玩家移动、NPC交互

var main: Node
const TILE = 32
const MOVE_SPD = 130.0

var tilemap: TileMapLayer
var player: Node2D
var camera: Camera2D
var hud: CanvasLayer
var map_data: Dictionary = {}

# 移动状态
var moving := false
var move_from := Vector2.ZERO
var move_to := Vector2.ZERO
var move_t := 0.0
var facing := 0  # 0下1左2右3上

var walk_timer := 0.0
var walk_frame := 0

func _ready():
	map_data = main.MapsDB.get_map(main.game_data.current_map)
	_build_tilemap()
	_build_player()
	_build_camera()
	_build_hud()
	_spawn_npcs_and_events()

func _build_tilemap():
	tilemap = TileMapLayer.new()
	tilemap.name = "TileMap"
	# 创建TileSet
	var ts = TileSet.new()
	var atlas = TileSetAtlasSource.new()
	var tex_path = "res://assets/tilesets/tileset.png"
	if ResourceLoader.exists(tex_path):
		atlas.texture = load(tex_path)
	atlas.tile_size = Vector2i(TILE, TILE)
	atlas.margin = Vector2i(0, 0)
	atlas.separation = Vector2i(0, 0)
	ts.add_source(atlas, 0)
	tilemap.tile_set = ts
	# 绘制瓦片
	var rows = map_data.get("tiles", [])
	for y in range(rows.size()):
		var row = rows[y]
		for x in range(row.length()):
			var c = row.ord_at(x) - 48  # char to int
			if c >= 0 and c <= 9:
				var ac = main.MapsDB.get_tile_atlas_coord(c)
				tilemap.set_cell(Vector2i(x, y), 0, ac)
	add_child(tilemap)

func _build_player():
	player = Node2D.new()
	player.name = "Player"
	player.position = Vector2(main.game_data.player_pos) * TILE
	# 精灵
	var sp = Sprite2D.new()
	sp.name = "Sprite"
	var hero_path = "res://assets/sprites/hero.png"
	if ResourceLoader.exists(hero_path):
		sp.texture = load(hero_path)
		sp.hframes = 4
		sp.vframes = 1
		sp.frame = 0
	player.add_child(sp)
	add_child(player)

func _build_camera():
	camera = Camera2D.new()
	camera.name = "Camera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_data.get("width", 20) * TILE
	camera.limit_bottom = map_data.get("height", 15) * TILE
	player.add_child(camera)

func _build_hud():
	hud = CanvasLayer.new()
	hud.name = "HUD"
	hud.layer = 50
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel.offset_right = 200
	panel.offset_bottom = 50
	var vbox = VBoxContainer.new()
	var hp_lbl = Label.new()
	hp_lbl.name = "HPLabel"
	hp_lbl.text = "HP: %d/%d" % [main.game_data.hp, main.game_data.max_hp]
	vbox.add_child(hp_lbl)
	var mp_lbl = Label.new()
	mp_lbl.name = "MPLabel"
	mp_lbl.text = "MP: %d/%d" % [main.game_data.mp, main.game_data.max_mp]
	vbox.add_child(mp_lbl)
	var gold_lbl = Label.new()
	gold_lbl.name = "GoldLabel"
	gold_lbl.text = "金币: %d  Lv.%d" % [main.game_data.gold, main.game_data.level]
	vbox.add_child(gold_lbl)
	var map_lbl = Label.new()
	map_lbl.name = "MapLabel"
	map_lbl.text = _map_display_name()
	vbox.add_child(map_lbl)
	panel.add_child(vbox)
	hud.add_child(panel)
	add_child(hud)

func _spawn_npcs_and_events():
	var npcs = map_data.get("npcs", [])
	for n in npcs:
		_spawn_npc(n)
	var events = map_data.get("events", [])
	for e in events:
		_spawn_event(e)

func _spawn_npc(data: Dictionary):
	var area = Area2D.new()
	area.position = Vector2(data["x"], data["y"]) * TILE
	var sp = Sprite2D.new()
	var path = "res://assets/sprites/%s.png" % data.get("sprite", "npc_villager")
	if ResourceLoader.exists(path):
		sp.texture = load(path)
		sp.hframes = 4
		sp.frame = 0
	area.add_child(sp)
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(TILE, TILE)
	col.shape = shape
	area.add_child(col)
	area.set_meta("npc", data)
	add_child(area)

func _spawn_event(data: Dictionary):
	var area = Area2D.new()
	area.position = Vector2(data["x"], data["y"]) * TILE
	# 根据类型显示不同外观
	var sp = Sprite2D.new()
	if data["type"] == "chest":
		var chest_id = data.get("switch", "")
		if chest_id in main.game_data.opened_chests:
			sp.frame = 9
		else:
			sp.frame = 6
	elif data["type"] == "save":
		sp.frame = 7
	elif data["type"] == "boss":
		sp.frame = 8
	elif data["type"] == "transfer":
		sp.frame = 4
	area.add_child(sp)
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(TILE, TILE)
	col.shape = shape
	area.add_child(col)
	area.set_meta("event", data)
	add_child(area)

func _get_tile_id(gx: int, gy: int) -> int:
	var rows = map_data.get("tiles", [])
	if gy < 0 or gy >= rows.size():
		return 1
	var row = rows[gy]
	if gx < 0 or gx >= row.length():
		return 1
	return row.ord_at(gx) - 48

func _is_solid(gx: int, gy: int) -> bool:
	var tid = _get_tile_id(gx, gy)
	return main.MapsDB.is_solid(tid)

func _physics_process(delta):
	# 更新HUD
	_update_hud()
	
	if get_tree().paused:
		return
	
	if not moving:
		# 读取输入
		var dx = 0
		var dy = 0
		if Input.is_action_pressed("move_up"): dy = -1; facing = 3
		elif Input.is_action_pressed("move_down"): dy = 1; facing = 0
		elif Input.is_action_pressed("move_left"): dx = -1; facing = 1
		elif Input.is_action_pressed("move_right"): dx = 1; facing = 2
		
		if dx != 0 or dy != 0:
			var cur_gx = int(player.position.x / TILE)
			var cur_gy = int(player.position.y / TILE)
			var nx = cur_gx + dx
			var ny = cur_gy + dy
			if not _is_solid(nx, ny):
				move_from = player.position
				move_to = Vector2(nx, ny) * TILE
				move_t = 0.0
				moving = true
				# 走路动画
				walk_timer += delta
				walk_frame = int(walk_timer * 4) % 2
		else:
			walk_frame = 0
		
		# 更新朝向精灵
		var sp = player.get_node_or_null("Sprite")
		if sp:
			sp.frame = facing
		
		# 交互
		if Input.is_action_just_pressed("interact"):
			_interact()
		
		# 菜单
		if Input.is_action_just_pressed("menu"):
			_open_menu()
	else:
		move_t += delta * MOVE_SPD / TILE
		if move_t >= 1.0:
			player.position = move_to
			moving = false
			move_t = 0.0
			# 到达新格子
			_on_tile_arrived()
		else:
			player.position = move_from.lerp(move_to, move_t)

func _on_tile_arrived():
	var gx = int(player.position.x / TILE)
	var gy = int(player.position.y / TILE)
	# 保存位置
	main.game_data.player_pos = Vector2i(gx, gy)
	
	# 检查事件
	var events = map_data.get("events", [])
	for e in events:
		if e["x"] == gx and e["y"] == gy:
			_handle_event(e)
			return
	
	# 随机遇敌
	var rate = map_data.get("encounter_rate", 0.0)
	if rate > 0 and randf() < rate:
		main._enter_battle()

func _handle_event(data: Dictionary):
	match data.get("type", ""):
		"transfer":
			var target_map = data.get("map", "town")
			var pos = data.get("pos", [10, 8])
			main.game_data.current_map = target_map
			main.game_data.player_pos = Vector2i(pos[0], pos[1])
			main._enter_world(target_map)
		"chest":
			var sw = data.get("switch", "")
			if sw in main.game_data.opened_chests:
				main.show_message("宝箱已经空了。")
				return
			var item_id = data.get("item", "")
			if main.game_data.add_item(item_id):
				main.game_data.opened_chests.append(sw)
				var iname = main.ItemsDB.get_item(item_id).get("name", item_id)
				main.show_message("获得了 %s！" % iname)
			else:
				main.show_message("背包已满！")
		"save":
			main.game_data.save_game()
			main.show_message("游戏已保存！")
		"boss":
			var sw = data.get("switch", "")
			if sw in main.game_data.defeated_enemies:
				main.show_message("这里已经没有敌人了。")
				return
			var boss_id = data.get("boss_id", "boss_goblin_king")
			main._enter_battle(boss_id, true)

func _interact():
	var gx = int(player.position.x / TILE)
	var gy = int(player.position.y / TILE)
	# 面朝方向
	var fx = gx
	var fy = gy
	match facing:
		0: fy += 1
		1: fx -= 1
		2: fx += 1
		3: fy -= 1
	
	# 检查NPC
	var npcs = map_data.get("npcs", [])
	for n in npcs:
		if n["x"] == fx and n["y"] == fy:
			_talk_to_npc(n)
			return
	
	# 检查事件
	var events = map_data.get("events", [])
	for e in events:
		if e["x"] == fx and e["y"] == fy:
			_handle_event(e)
			return

func _talk_to_npc(data: Dictionary):
	var dialogs = data.get("dialog", [])
	var name = data.get("name", "???")
	var shop = data.get("shop", [])
	
	if shop.size() > 0:
		# 有商店的NPC
		main.show_dialog(dialogs, name, func():
			if shop.size() > 0:
				_open_shop(shop, name)
		)
	else:
		main.show_dialog(dialogs, name)

func _open_shop(shop_items: Array, shop_name: String):
	var overlay = CanvasLayer.new()
	overlay.name = "ShopOverlay"
	overlay.layer = 100
	
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = 40
	panel.offset_top = 20
	panel.offset_right = 440
	panel.offset_bottom = 300
	
	var vbox = VBoxContainer.new()
	var title = Label.new()
	title.text = "%s 的商店" % shop_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	var gold_lbl = Label.new()
	gold_lbl.text = "金币: %d" % main.game_data.gold
	gold_lbl.name = "GoldLabel"
	vbox.add_child(gold_lbl)
	
	for item_id in shop_items:
		var info = main.ItemsDB.get_item(item_id)
		if info.is_empty():
			continue
		var hbox = HBoxContainer.new()
		var name_lbl = Label.new()
		name_lbl.text = "%s (%dG)" % [info.get("name", item_id), info.get("price", 0)]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(name_lbl)
		var btn = Button.new()
		btn.text = "购买"
		var iid = item_id
		var price = info.get("price", 0)
		btn.pressed.connect(func():
			if main.game_data.gold >= price:
				main.game_data.gold -= price
				main.game_data.add_item(iid)
				gold_lbl.text = "金币: %d" % main.game_data.gold
			else:
				gold_lbl.text = "金币不足！"
		)
		hbox.add_child(btn)
		vbox.add_child(hbox)
	
	var close_btn = Button.new()
	close_btn.text = "离开商店"
	close_btn.pressed.connect(func():
		get_tree().paused = false
		overlay.queue_free()
	)
	vbox.add_child(close_btn)
	
	panel.add_child(vbox)
	overlay.add_child(panel)
	add_child(overlay)

func _open_menu():
	var overlay = CanvasLayer.new()
	overlay.name = "MenuOverlay"
	overlay.layer = 100
	
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = 80
	panel.offset_top = 40
	panel.offset_right = 400
	panel.offset_bottom = 280
	
	var vbox = VBoxContainer.new()
	var title = Label.new()
	title.text = "=== 菜单 ==="
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# 状态
	var status_text = "Lv.%d  HP:%d/%d  MP:%d/%d\nATK:%d  DEF:%d  SPD:%d\nEXP:%d/%d  金币:%d" % [
		main.game_data.level, main.game_data.hp, main.game_data.max_hp,
		main.game_data.mp, main.game_data.max_mp,
		main.game_data.get_atk(), main.game_data.get_def(), main.game_data.get_spd(),
		main.game_data.exp, main.game_data.exp_needed(), main.game_data.gold
	]
	var status = Label.new()
	status.text = status_text
	vbox.add_child(status)
	
	# 物品
	var items_text = "=== 物品 ===\n"
	if main.game_data.inventory.is_empty():
		items_text += "(空)"
	else:
		for item in main.game_data.inventory:
			var info = main.ItemsDB.get_item(item["id"])
			items_text += "%s x%d\n" % [info.get("name", item["id"]), item.get("amount", 1)]
	var items_lbl = Label.new()
	items_lbl.text = items_text
	vbox.add_child(items_lbl)
	
	# 装备
	var equip_text = "=== 装备 ===\n"
	equip_text += "武器: %s\n" % main.game_data.weapon.get("name", "无")
	equip_text += "防具: %s\n" % main.game_data.armor.get("name", "无")
	equip_text += "饰品: %s\n" % main.game_data.accessory.get("name", "无")
	var equip_lbl = Label.new()
	equip_lbl.text = equip_text
	vbox.add_child(equip_lbl)
	
	# 按钮
	var hbox = HBoxContainer.new()
	var save_btn = Button.new()
	save_btn.text = "存档"
	save_btn.pressed.connect(func():
		main.game_data.save_game()
		save_btn.text = "已保存!"
	)
	hbox.add_child(save_btn)
	var close_btn = Button.new()
	close_btn.text = "关闭"
	close_btn.pressed.connect(func():
		get_tree().paused = false
		overlay.queue_free()
	)
	hbox.add_child(close_btn)
	vbox.add_child(hbox)
	
	panel.add_child(vbox)
	overlay.add_child(panel)
	get_tree().paused = true
	add_child(overlay)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if get_tree().paused:
			# 在对话框中按空格推进
			for child in get_tree().root.get_children():
				if child is CanvasLayer and child.name == "DialogOverlay":
					main.advance_dialog(child)
					get_viewport().set_input_as_handled()
					return

func _update_hud():
	if not hud:
		return
	var hp = hud.get_node_or_null("PanelContainer/VBoxContainer/HPLabel")
	var mp = hud.get_node_or_null("PanelContainer/VBoxContainer/MPLabel")
	var gold = hud.get_node_or_null("PanelContainer/VBoxContainer/GoldLabel")
	if hp:
		hp.text = "HP: %d/%d" % [main.game_data.hp, main.game_data.max_hp]
	if mp:
		mp.text = "MP: %d/%d" % [main.game_data.mp, main.game_data.max_mp]
	if gold:
		gold.text = "金币: %d  Lv.%d" % [main.game_data.gold, main.game_data.level]

func _map_display_name() -> String:
	match main.game_data.current_map:
		"town": return "起始之村"
		"grassland": return "大草原"
		"forest": return "迷雾森林"
		"cave": return "古代洞穴"
		"castle": return "暗黑城堡"
		_: return main.game_data.current_map
