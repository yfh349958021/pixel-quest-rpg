extends CanvasLayer

func _ready() -> void:
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	
	var title = Label.new()
	title.text = "⏸ 游戏菜单"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	_make_btn(vbox, "💾 保存游戏", func():
		SaveGameManager.save_game()
		queue_free()
	)
	_make_btn(vbox, "🎮 继续游戏", func():
		queue_free()
	)
	_make_btn(vbox, "🏠 返回主菜单", func():
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		queue_free()
	)

func _make_btn(parent: Control, text: String, callback: Callable) -> void:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 36)
	btn.pressed.connect(callback)
	parent.add_child(btn)
