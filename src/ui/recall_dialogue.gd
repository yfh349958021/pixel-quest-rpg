extends Control
## 回想对话浏览 - 可选择任意阶段对话查看

@onready var npc_title: Label = $VBoxContainer/NPCTitle
@onready var phase_buttons: HBoxContainer = $VBoxContainer/PhaseButtons
@onready var dialogue_area: VBoxContainer = $VBoxContainer/ScrollContainer/DialogueArea
@onready var btn_back: Button = $VBoxContainer/HBox/BtnBack

var _npc_name: String = ""
var _current_phase: int = 1
var _max_phase: int = 0
var _phase_labels: Array = [
	"",
	"路人对话",
	"略有好感",
	"恋人对话",
	"恋人做爱",
	"结婚做爱",
	"怀孕做爱",
]

func _ready() -> void:
	btn_back.pressed.connect(_on_back)
	_build_phase_buttons()
	# 从meta读取recall_room传来的NPC名
	if has_meta("recall_npc"):
		_npc_name = get_meta("recall_npc")
		npc_title.text = _npc_name + " 的对话"
		_max_phase = DialogueManager.get_max_talk_count(_npc_name)
		# 启用可用阶段按钮
		for i in range(phase_buttons.get_child_count()):
			var btn: Button = phase_buttons.get_child(i)
			if i < _max_phase:
				btn.disabled = false
		if _max_phase > 0:
			_show_phase(1)
	else:
		npc_title.text = "回想房间 - 选择角色"

func _build_phase_buttons() -> void:
	for child in phase_buttons.get_children():
		child.queue_free()
	for i in range(1, 7):
		var btn := Button.new()
		btn.text = _phase_labels[i]
		btn.disabled = true
		var phase: int = i
		btn.pressed.connect(func(): _show_phase(phase))
		phase_buttons.add_child(btn)

func _clear_dialogue_area() -> void:
	for child in dialogue_area.get_children():
		child.queue_free()

func _show_phase(phase: int) -> void:
	_current_phase = phase
	_clear_dialogue_area()
	var lines: Array = DialogueManager._load_talk(_npc_name, phase)
	if lines.is_empty():
		var label := Label.new()
		label.text = "（该阶段对话尚未编写）"
		dialogue_area.add_child(label)
	else:
		for line: Dictionary in lines:
			var hbox := HBoxContainer.new()
			var speaker := Label.new()
			speaker.text = line.get("speaker", "")
			speaker.custom_minimum_size.x = 80
			speaker.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
			var text := RichTextLabel.new()
			text.fit_content = true
			text.bbcode_enabled = true
			text.text = line.get("text", "")
			text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(speaker)
			hbox.add_child(text)
			var cg_idx: String = line.get("cg_index", "")
			if cg_idx != "":
				var cg := Label.new()
				cg.text = "[" + cg_idx + "]"
				cg.custom_minimum_size.x = 40
				cg.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
				hbox.add_child(cg)
			dialogue_area.add_child(hbox)
	# 高亮当前阶段按钮
	for i in range(phase_buttons.get_child_count()):
		var btn: Button = phase_buttons.get_child(i)
		btn.modulate = Color.WHITE if (i + 1) == phase else Color(0.5, 0.5, 0.5)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/RecallRoom.tscn")
