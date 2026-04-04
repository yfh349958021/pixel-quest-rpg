extends Node2D

var game_data: Node
var current_screen: Node = null
var current_map_id: String = "town"

# 预加载数据库脚本
var ItemsDB = preload("res://src/data/items.gd")
var EnemiesDB = preload("res://src/data/enemies.gd")
var SkillsDB = preload("res://src/data/skills.gd")
var MapsDB = preload("res://src/data/maps.gd")

func _ready():
	game_data = Node.new()
	game_data.set_script(preload("res://src/data/game_data.gd"))
	game_data.name = "GameData"
	add_child(game_data)
	_enter_title()

func _enter_title():
	_clear_screen()
	var s = CanvasLayer.new()
	s.name = "TitleScreen"
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	s.add_child(bg)
	var title = Label.new()
	title.text = "像素奇幻 RPG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 60)
	title.size = Vector2(480, 50)
	title.add_theme_font_size_override("font_size", 28)
	s.add_child(title)
	var ver = Label.new()
	ver.text = "v1.0 - Godot Engine"
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.position = Vector2(0, 110)
	ver.size = Vector2(480, 20)
	s.add_child(ver)
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(170, 160)
	vbox.size = Vector2(140, 100)
	var new_btn = Button.new()
	new_btn.text = "新游戏"
	new_btn.pressed.connect(_on_new_game)
	vbox.add_child(new_btn)
	var cont_btn = Button.new()
	cont_btn.text = "继续游戏"
	cont_btn.pressed.connect(_on_continue)
	cont_btn.disabled = not game_data.has_save()
	vbox.add_child(cont_btn)
	s.add_child(vbox)
	var hint = Label.new()
	hint.text = "WASD/方向键移动 空格交互 ESC菜单"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, 290)
	hint.size = Vector2(480, 20)
	s.add_child(hint)
	add_child(s)
	current_screen = s

func _on_new_game():
	game_data.new_game()
	_enter_world("town")

func _on_continue():
	if game_data.load_game():
		_enter_world(game_data.current_map)

func _enter_world(map_id: String):
	_clear_screen()
	current_map_id = map_id
	game_data.current_map = map_id
	var w = Node2D.new()
	w.name = "WorldScreen"
	w.set_script(preload("res://src/world_screen.gd"))
	w.main = self
	w.ItemsDB = ItemsDB
	w.EnemiesDB = EnemiesDB
	w.SkillsDB = SkillsDB
	w.MapsDB = MapsDB
	add_child(w)
	current_screen = w

func _enter_battle(enemy_id: String = "", is_boss: bool = false):
	_clear_screen()
	var b = CanvasLayer.new()
	b.name = "BattleScreen"
	b.set_script(preload("res://src/battle_screen.gd"))
	b.main = self
	b.enemy_id = enemy_id
	b.is_boss = is_boss
	b.ItemsDB = ItemsDB
	b.EnemiesDB = EnemiesDB
	b.SkillsDB = SkillsDB
	b.MapsDB = MapsDB
	add_child(b)
	current_screen = b

func _enter_world_after_battle():
	_enter_world(current_map_id)

func _clear_screen():
	if current_screen:
		current_screen.queue_free()
		current_screen = null

func show_dialog(dialogs: Array, speaker: String = "", callback: Callable = Callable()):
	var overlay = CanvasLayer.new()
	overlay.name = "DialogOverlay"
	overlay.layer = 100
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -100
	panel.offset_bottom = 0
	var vbox = VBoxContainer.new()
	var spk = Label.new()
	spk.text = speaker
	spk.add_theme_font_size_override("font_size", 14)
	vbox.add_child(spk)
	var txt = Label.new()
	txt.name = "TextLabel"
	txt.text = dialogs[0] if dialogs.size() > 0 else ""
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_font_size_override("font_size", 14)
	vbox.add_child(txt)
	var hint = Label.new()
	hint.text = "[SPACE]"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 10)
	vbox.add_child(hint)
	panel.add_child(vbox)
	overlay.add_child(panel)
	overlay.set_meta("dialogs", dialogs)
	overlay.set_meta("index", 1)
	overlay.set_meta("speaker", speaker)
	overlay.set_meta("callback", callback)
	get_tree().paused = true
	add_child(overlay)

func advance_dialog(overlay: CanvasLayer):
	var idx = overlay.get_meta("index", 0)
	var dialogs = overlay.get_meta("dialogs", [])
	if idx >= dialogs.size():
		var cb: Callable = overlay.get_meta("callback", Callable())
		get_tree().paused = false
		overlay.queue_free()
		if cb.is_valid():
			cb.call()
		return
	var txt = overlay.get_node_or_null("PanelContainer/VBoxContainer/TextLabel")
	if txt:
		txt.text = dialogs[idx]
	overlay.set_meta("index", idx + 1)

func show_message(text: String, callback: Callable = Callable()):
	show_dialog([text], "", callback)
