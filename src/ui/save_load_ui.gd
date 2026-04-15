extends Control
## 存档/读档槽位界面
## 3x3九宫格布局, 槽位1为自动保存(只读)

signal back_pressed()
signal slot_selected(slot: int)

var _mode: String = ""  # "save" / "load"
var _slot_buttons: Array = []

@onready var title_label: Label = $MarginContainer/VBox/Title
@onready var grid: GridContainer = $MarginContainer/VBox/GridContainer
@onready var btn_back: Button = $MarginContainer/VBox/HBox/BtnBack
@onready var detail_label: Label = $MarginContainer/VBox/Detail

func _ready() -> void:
	hide()
	btn_back.pressed.connect(func(): back_pressed.emit())
	_build_slots()

func setup_mode(mode: String) -> void:
	_mode = mode
	if mode == "save":
		title_label.text = "保存游戏"
	elif mode == "load":
		title_label.text = "载入游戏"
	detail_label.text = ""
	refresh_slots()

func refresh_slots() -> void:
	for i in range(_slot_buttons.size()):
		var info: Dictionary = SaveManager.get_slot_info(i)
		var btn: Button = _slot_buttons[i]
		if info.get("exists", false):
			var label: String = ""
			if info.get("is_auto", false):
				label = "[自动保存] "
			label += info.get("current_map", "未知位置")
			btn.text = label
			btn.disabled = false
			# 显示详情
		else:
			if info.get("is_auto", false):
				btn.text = "[自动保存] 空"
				btn.disabled = true
			else:
				btn.text = "--- 空存档 ---"
				btn.disabled = (_mode == "load")

func _build_slots() -> void:
	# 清理旧的
	for child in grid.get_children():
		child.queue_free()
	_slot_buttons.clear()
	
	for i in range(SaveManager.MAX_SLOTS):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(220, 80)
		btn.text = "--- 空存档 ---"
		var slot: int = i
		btn.pressed.connect(func(): _on_slot_clicked(slot))
		grid.add_child(btn)
		_slot_buttons.append(btn)

func _on_slot_clicked(slot: int) -> void:
	var info: Dictionary = SaveManager.get_slot_info(slot)
	var detail: String = ""
	if info.get("exists", false):
		detail = "位置: " + info.get("current_map", "?")
		detail += "  |  游玩时间: " + info.get("play_time_str", "00:00:00")
		if info.get("timestamp", "") != "":
			detail += "\n保存时间: " + info.get("timestamp", "")
	detail_label.text = detail
	slot_selected.emit(slot)
