extends Node2D

var player: Node2D
var camera: Camera2D
var tile_map: TileMap
var ui_layer: CanvasLayer
var hud_panel: Panel
var inventory_panel: Panel
var tool_panel: Panel
var dialogue_panel: PanelContainer
var day_night: CanvasModulate
var objects_layer: Node2D
var npcs_layer: Node2D

func _ready() -> void:
	_build_world()
	_build_player()
	_build_ui()
	_build_npcs()
	_setup_day_night()
	GameDialogueManager.show_dialogue.connect(_show_dialogue)

func _build_world() -> void:
	# 地图层
	var grass_tex = load("res://assets/sprites/tilesets/Grass.png")
	if not grass_tex:
		return
	
	var tile_set = TileSet.new()
	var source = TileSetAtlasSource.new()
	source.texture = grass_tex
	source.region = Rect2(0, 0, grass_tex.get_width(), grass_tex.get_height())
	source.tile_size = Vector2i(16, 16)
	
	# 分析tileset: 176x112, tile=16x16 => 11 cols x 7 rows
	var cols = grass_tex.get_width() // 16
	var rows = grass_tex.get_height() // 16
	for row in range(rows):
		for col in range(cols):
			var atlas_coords = Vector2i(col, row)
			source.create_tile(atlas_coords)
			# 创建备选帧（如果有不同状态）
	
	tile_set.add_source(source)
	
	# 添加碰撞层（第2行通常是不可通行的）
	var phys_layer = TileSetPhysicsLayer.new()
	phys_layer.collision_layer = 1
	tile_set.add_physics_layer(0)
	# 标记某些tile为碰撞（比如水面、栅栏等）
	
	tile_map = TileMap.new()
	tile_map.tile_set = tile_set
	add_child(tile_map)
	
	# 绘制一个大的草地地图 (40x25 tiles = 640x400)
	var map_size = Vector2i(40, 25)
	for y in range(map_size.y):
		for x in range(map_size.x):
			# 随机选择草地变体（第0行有不同草地样式）
			var tile_id = Vector2i(randi() % 4, 0)  # 第0行的前4个tile
			if x == 0 or x == map_size.x - 1 or y == 0 or y == map_size.y - 1:
				tile_id = Vector2i(0, 0)  # 边界用统一tile
			tile_map.set_cell(0, Vector2i(x, y), 0, tile_id)
	
	# 物品层
	objects_layer = Node2D.new()
	objects_layer.name = "Objects"
	add_child(objects_layer)
	npcs_layer = Node2D.new()
	npcs_layer.name = "NPCs"
	add_child(npcs_layer)
	
	# 放置一些树
	_plant_trees()
	# 放置石头
	_place_rocks()
	# 放置箱子
	_place_chests()

func _plant_trees() -> void:
	for i in range(8):
		var pos = Vector2(randi_range(2, 35) * 16, randi_range(2, 22) * 16)
		var tree = _create_tree(pos)
		objects_layer.add_child(tree)

func _place_rocks() -> void:
	for i in range(5):
		var pos = Vector2(randi_range(3, 36) * 16, randi_range(3, 21) * 16)
		var rock = _create_rock(pos)
		objects_layer.add_child(rock)

func _place_chests() -> void:
	var positions = [Vector2(5 * 16, 5 * 16), Vector2(30 * 16, 20 * 16)]
	for pos in positions:
		var chest = _create_chest(pos)
		objects_layer.add_child(chest)

func _create_tree(pos: Vector2) -> Node2D:
	var tree = Node2D.new()
	tree.position = pos
	tree.name = "Tree"
	
	var tex = load("res://assets/sprites/objects/grass_deco.png")
	if tex:
		# 从grass_deco中裁剪一个树（使用大树的区域）
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.region_enabled = true
		sprite.region = Rect2(96, 16, 32, 48)
		sprite.offset = Vector2(0, -16)
		tree.add_child(sprite)
	
	# 碰撞区域
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(16, 12)
	col.shape = shape
	col.position = Vector2(0, 4)
	tree.add_child(col)
	
	# HurtComponent for chopping
	var area = Area2D.new()
	area.name = "HurtComponent"
	var area_shape = CollisionShape2D.new()
	var area_rect = RectangleShape2D.new()
	area_rect.size = Vector2(20, 20)
	area_shape.shape = area_rect
	area.add_child(area_shape)
	tree.add_child(area)
	
	return tree

func _create_rock(pos: Vector2) -> Node2D:
	var rock = Node2D.new()
	rock.position = pos
	rock.name = "Rock"
	
	var tex = load("res://assets/sprites/objects/tools_materials.png")
	if tex:
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.region_enabled = true
		sprite.region = Rect2(16, 0, 16, 16)
		rock.add_child(sprite)
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(14, 14)
	col.shape = shape
	rock.add_child(col)
	
	var area = Area2D.new()
	area.name = "HurtComponent"
	var area_shape = CollisionShape2D.new()
	var area_rect = RectangleShape2D.new()
	area_rect.size = Vector2(18, 18)
	area_shape.shape = area_rect
	area.add_child(area_shape)
	rock.add_child(area)
	
	return rock

func _create_chest(pos: Vector2) -> Node2D:
	var chest = Node2D.new()
	chest.position = pos
	chest.name = "Chest"
	
	var tex = load("res://assets/sprites/objects/Chest.png")
	if tex:
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.hframes = 5
		sprite.vframes = 2
		sprite.frame = 0
		sprite.name = "AnimatedSprite2D"
		chest.add_child(sprite)
	
	var area = Area2D.new()
	area.name = "InteractableComponent"
	var area_shape = CollisionShape2D.new()
	var area_rect = RectangleShape2D.new()
	area_rect.size = Vector2(24, 16)
	area_shape.shape = area_rect
	area.add_child(area_shape)
	chest.add_child(area)
	
	return chest

func _build_player() -> void:
	player = CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector2(20 * 16, 12 * 16)
	
	# 碰撞
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(12, 14)
	col.shape = shape
	col.position = Vector2(0, 2)
	player.add_child(col)
	
	# 精灵
	var tex = load("res://assets/sprites/characters/Basic Charakter Spritesheet.png")
	if tex:
		var sprite = AnimatedSprite2D.new()
		sprite.name = "AnimatedSprite2D"
		sprite.texture = tex
		sprite.hframes = 6
		sprite.vframes = 4
		sprite.frame = 1  # idle front
		player.add_child(sprite)
	
	# Hit component (工具攻击区域)
	var hit_area = Area2D.new()
	hit_area.name = "HitComponent"
	var hit_shape = CollisionShape2D.new()
	var hit_rect = RectangleShape2D.new()
	hit_rect.size = Vector2(16, 16)
	hit_shape.shape = hit_rect
	hit_area.add_child(hit_shape)
	player.add_child(hit_area)
	
	add_child(player)
	
	# 相机
	camera = Camera2D.new()
	camera.zoom = Vector2(2, 2)
	player.add_child(camera)

func _build_npcs() -> void:
	# 村民NPC
	var npc_positions = [
		Vector2(15 * 16, 8 * 16),
		Vector2(25 * 16, 15 * 16),
	]
	var npc_dialogs = [
		["欢迎来到萌芽之地！", "这里很适合种田哦~"],
		["今天天气真好！", "要不要一起去钓鱼？"],
	]
	for i in range(npc_positions.size()):
		var npc = _create_npc(npc_positions[i], "村民" + str(i+1), npc_dialogs[i])
		npcs_layer.add_child(npc)

func _create_npc(pos: Vector2, name: String, lines: Array) -> Node2D:
	var npc = CharacterBody2D.new()
	npc.name = name
	npc.position = pos
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(12, 14)
	col.shape = shape
	col.position = Vector2(0, 2)
	npc.add_child(col)
	
	var tex = load("res://assets/sprites/characters/Basic Charakter Spritesheet.png")
	if tex:
		var sprite = AnimatedSprite2D.new()
		sprite.name = "AnimatedSprite2D"
		sprite.texture = tex
		sprite.hframes = 6
		sprite.vframes = 4
		sprite.frame = 1
		npc.add_child(sprite)
	
	var area = Area2D.new()
	area.name = "InteractableComponent"
	var area_shape = CollisionShape2D.new()
	var area_rect = RectangleShape2D.new()
	area_rect.size = Vector2(24, 24)
	area_shape.shape = area_rect
	area.add_child(area_shape)
	npc.add_child(area)
	
	return npc

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UI"
	add_child(ui_layer)
	
	# HUD
	hud_panel = Panel.new()
	hud_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	hud_panel.custom_minimum_size = Vector2(200, 50)
	ui_layer.add_child(hud_panel)
	
	var hud_hbox = HBoxContainer.new()
	hud_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_hbox.add_theme_constant_override("separation", 10)
	hud_panel.add_child(hud_hbox)
	
	# 时间显示
	var time_label = Label.new()
	time_label.name = "TimeLabel"
	time_label.text = "第1天 08:00"
	time_label.add_theme_font_size_override("font_size", 14)
	hud_hbox.add_child(time_label)
	
	DayAndNightCycleManager.time_tick.connect(func(day, hour, minute):
		time_label.text = "第%d天 %02d:%02d" % [day + 1, hour, minute]
	)
	
	# 工具栏
	tool_panel = Panel.new()
	tool_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	tool_panel.custom_minimum_size = Vector2(0, 50)
	ui_layer.add_child(tool_panel)
	
	var tool_hbox = HBoxContainer.new()
	tool_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tool_hbox.add_theme_constant_override("separation", 5)
	tool_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tool_panel.add_child(tool_hbox)
	
	var tools = [
		["🪓 斧头", DataTypes.Tools.AxeWood],
		["⛏ 锄头", DataTypes.Tools.TillGround],
		["💧 浇水", DataTypes.Tools.WaterCrops],
		["🌽 玉米", DataTypes.Tools.PlantCorn],
		["🍅 番茄", DataTypes.Tools.PlantTomato],
	]
	for tool_info in tools:
		var btn = Button.new()
		btn.text = tool_info[0]
		btn.custom_minimum_size = Vector2(70, 36)
		btn.pressed.connect(func():
			ToolManager.select_tool(tool_info[1])
		)
		tool_hbox.add_child(btn)
	
	# 物品栏
	inventory_panel = PanelContainer.new()
	inventory_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	inventory_panel.visible = false
	ui_layer.add_child(inventory_panel)
	
	var inv_vbox = VBoxContainer.new()
	inv_vbox.add_theme_constant_override("separation", 5)
	inventory_panel.add_child(inv_vbox)
	
	var inv_title = Label.new()
	inv_title.text = "📦 背包"
	inv_title.add_theme_font_size_override("font_size", 16)
	inv_vbox.add_child(inv_title)
	
	var inv_label = Label.new()
	inv_label.name = "InventoryLabel"
	inv_label.text = "空"
	inv_vbox.add_child(inv_label)
	
	InventoryManager.inventory_changed.connect(func():
		var text = ""
		for item in InventoryManager.inventory:
			text += "%s x%d\n" % [item, InventoryManager.inventory[item]]
		inv_label.text = text if text else "空"
	)
	
	# 对话框
	dialogue_panel = PanelContainer.new()
	dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	dialogue_panel.offset_top = -120
	dialogue_panel.visible = false
	ui_layer.add_child(dialogue_panel)
	
	var dia_vbox = VBoxContainer.new()
	dia_vbox.add_theme_constant_override("separation", 8)
	dialogue_panel.add_child(dia_vbox)
	
	var dia_speaker = Label.new()
	dia_speaker.name = "SpeakerLabel"
	dia_speaker.text = ""
	dia_speaker.add_theme_font_size_override("font_size", 14)
	dia_vbox.add_child(dia_speaker)
	
	var dia_text = Label.new()
	dia_text.name = "TextLabel"
	dia_text.text = ""
	dia_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dia_vbox.add_child(dia_text)
	
	var dia_hint = Label.new()
	dia_hint.text = "[E] 继续..."
	dia_hint.add_theme_font_size_override("font_size", 10)
	dia_vbox.add_child(dia_hint)
	
	GameDialogueManager.show_dialogue.connect(_show_dialogue)

var _dialogue_queue: Array = []
var _dialogue_index: int = 0

func _show_dialogue(lines: Array) -> void:
	if not lines or lines.size() == 0:
		return
	_dialogue_queue = lines
	_dialogue_index = 0
	dialogue_panel.visible = true
	_display_current_line()

func _display_current_line() -> void:
	if _dialogue_index >= _dialogue_queue.size():
		dialogue_panel.visible = false
		return
	var speaker = dialogue_panel.get_node_or_null("SpeakerLabel")
	var text_label = dialogue_panel.get_node_or_null("TextLabel")
	if speaker:
		speaker.text = "💬"
	if text_label:
		text_label.text = str(_dialogue_queue[_dialogue_index])

func _unhandled_input(event: InputEvent) -> void:
	if dialogue_panel and dialogue_panel.visible:
		if event.is_action_pressed("show_dialogue") or event.is_action_pressed("ui_accept"):
			_dialogue_index += 1
			if _dialogue_index >= _dialogue_queue.size():
				dialogue_panel.visible = false
			else:
				_display_current_line()
			get_viewport().set_input_as_handled()
	
	# TAB键切换背包
	if event.is_action_pressed("game_menu"):
		if inventory_panel:
			inventory_panel.visible = not inventory_panel.visible
		get_viewport().set_input_as_handled()

func _setup_day_night() -> void:
	day_night = CanvasModulate.new()
	day_night.name = "DayNight"
	day_night.color = Color.WHITE
	add_child(day_night)
	
	DayAndNightCycleManager.game_time.connect(func(t):
		var sample = 0.5 * (sin(t - PI * 0.5) + 1.0)
		day_night.color = Color(sample * 0.5 + 0.5, sample * 0.5 + 0.5, sample * 0.7 + 0.3)
	)
