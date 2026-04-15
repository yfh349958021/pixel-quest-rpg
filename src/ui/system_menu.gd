extends CanvasLayer
## 系统菜单(ESC暂停菜单)
## 游戏中按ESC呼出, 主菜单中不显示

@onready var panel: Panel = $Panel
@onready var vbox: VBoxContainer = $Panel/MarginContainer/VBox
@onready var btn_continue: Button = $Panel/MarginContainer/VBox/BtnContinue
@onready var btn_load: Button = $Panel/MarginContainer/VBox/BtnLoad
@onready var btn_save: Button = $Panel/MarginContainer/VBox/BtnSave
@onready var btn_main_menu: Button = $Panel/MarginContainer/VBox/BtnMainMenu
@onready var btn_exit: Button = $Panel/MarginContainer/VBox/BtnExit
@onready var save_load_ui: Control = $SaveLoadUI

var _mode: String = ""  # "save" / "load" / ""

func _ready() -> void:
	hide()
	btn_continue.pressed.connect(_on_continue)
	btn_load.pressed.connect(_on_load)
	btn_save.pressed.connect(_on_save)
	btn_main_menu.pressed.connect(_on_main_menu)
	btn_exit.pressed.connect(_on_exit)
	save_load_ui.back_pressed.connect(_on_save_load_back)
	save_load_ui.slot_selected.connect(_on_slot_selected)

func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		if _mode != "":
			_on_save_load_back()
		else:
			_close()

## 打开系统菜单(从GameWorld调用)
func open_menu() -> void:
	_mode = ""
	save_load_ui.hide()
	show()
	get_tree().paused = true

func _close() -> void:
	_mode = ""
	save_load_ui.hide()
	hide()
	get_tree().paused = false

func _on_continue() -> void:
	_close()

func _on_load() -> void:
	_mode = "load"
	save_load_ui.setup_mode("load")
	save_load_ui.show()

func _on_save() -> void:
	_mode = "save"
	save_load_ui.setup_mode("save")
	save_load_ui.show()

func _on_main_menu() -> void:
	_close()
	SaveManager.stop_auto_save()
	GameManager.stop_play_time()
	get_tree().paused = false
	SceneManager.goto_scene("res://scenes/MainMenu.tscn")

func _on_exit() -> void:
	get_tree().quit()

func _on_save_load_back() -> void:
	_mode = ""
	save_load_ui.hide()

func _on_slot_selected(slot: int) -> void:
	if _mode == "load":
		if SaveManager.load_from_slot(slot):
			_close()
			SaveManager.stop_auto_save()
			get_tree().paused = false
			SceneManager.goto_scene("res://scenes/GameWorld.tscn")
	elif _mode == "save":
		if slot == SaveManager.AUTO_SAVE_SLOT:
			return  # 不允许手动覆盖自动保存
		var info: Dictionary = SaveManager.get_slot_info(slot)
		if info.get("exists", false):
			# 已有存档, 让用户确认覆盖 - 使用内联确认
			_confirm_overwrite(slot)
		else:
			_do_save(slot)

func _do_save(slot: int) -> void:
	if SaveManager.save_to_slot(slot):
		save_load_ui.refresh_slots()
		_mode = ""
		save_load_ui.hide()

## 覆盖确认 - 在save_load_ui上显示确认框
var _confirm_panel: PanelContainer = null
var _confirm_slot: int = -1

func _confirm_overwrite(slot: int) -> void:
	if _confirm_panel and is_instance_valid(_confirm_panel):
		_confirm_panel.queue_free()
	_confirm_slot = slot
	_confirm_panel = PanelContainer.new()
	_confirm_panel.name = "ConfirmOverwrite"
	_confirm_panel.set_anchors_preset(Control.PRESET_CENTER)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	var label := Label.new()
	label.text = "确定覆盖此存档吗？"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	var btn_yes := Button.new()
	btn_yes.text = "确定"
	btn_yes.pressed.connect(_on_confirm_yes)
	var btn_no := Button.new()
	btn_no.text = "取消"
	btn_no.pressed.connect(_on_confirm_no)
	hbox.add_child(btn_yes)
	hbox.add_child(btn_no)
	vbox.add_child(label)
	vbox.add_child(hbox)
	_confirm_panel.add_child(vbox)
	add_child(_confirm_panel)

func _on_confirm_yes() -> void:
	if _confirm_slot >= 0:
		_do_save(_confirm_slot)
	_confirm_slot = -1
	if _confirm_panel and is_instance_valid(_confirm_panel):
		_confirm_panel.queue_free()

func _on_confirm_no() -> void:
	_confirm_slot = -1
	if _confirm_panel and is_instance_valid(_confirm_panel):
		_confirm_panel.queue_free()
