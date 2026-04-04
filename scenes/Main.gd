extends Control

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.color = Color(0.4, 0.6, 0.3)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.add_theme_constant_override("separation", 15)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "🌱 萌芽之地"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)
	
	var sub = Label.new()
	sub.text = "农场物语"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	vbox.add_child(sub)
	
	var ver = Label.new()
	ver.text = "v1.0 - Godot 4.5"
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.add_theme_font_size_override("font_size", 12)
	vbox.add_child(ver)
	
	vbox.add_child(HSeparator.new())
	
	_new_button(vbox, "🎮 开始新游戏", _on_new_game)
	_new_button(vbox, "📂 继续游戏", _on_continue)
	_new_button(vbox, "🚪 退出", _on_exit)

func _new_button(parent: Control, text: String, callback: Callable) -> void:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 40)
	btn.pressed.connect(callback)
	parent.add_child(btn)

func _on_new_game() -> void:
	GameManager.start_game()

func _on_continue() -> void:
	SaveGameManager.load_game()
	GameManager.start_game()

func _on_exit() -> void:
	GameManager.exit_game()
