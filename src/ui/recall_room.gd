extends Control
## 回想房间 - 浏览所有高级NPC对话

@onready var scroll: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/NPCCardGrid
@onready var btn_back: Button = $HBox/BtnBack

var _core_npcs: Array = [
	{"name": "艾琳", "map": "蓝河村", "age": "18"},
	{"name": "罗莎", "map": "暴风酒馆", "age": "28"},
	{"name": "艾琳娜", "map": "风暴教堂", "age": "24"},
	{"name": "莉娜", "map": "风岩城·街道", "age": "22"},
	{"name": "海伦娜", "map": "蓝河村", "age": "30"},
	{"name": "格蕾丝", "map": "风岩城·街道", "age": "26"},
	{"name": "薇拉", "map": "蓝河村", "age": "21"},
	{"name": "米拉", "map": "暴风酒馆", "age": "23"},
	{"name": "赛琳", "map": "北方冰原小径", "age": "25"},
	{"name": "芙蕾雅", "map": "风岩城·市场", "age": "45"},
	{"name": "伊莎贝拉", "map": "金贸王国", "age": "22"},
	{"name": "维多利亚", "map": "风岩城·市场", "age": "27"},
	{"name": "露娜", "map": "风岩城·街道", "age": "29"},
	{"name": "奥莉维亚", "map": "风岩城·街道", "age": "20"},
	{"name": "蕾娅", "map": "风岩城·市场", "age": "19"},
	{"name": "安娜", "map": "风暴教堂", "age": "31"},
	{"name": "索菲亚", "map": "金贸王国", "age": "35"},
	{"name": "妮可", "map": "暴风酒馆", "age": "24"},
	{"name": "梅林达", "map": "风岩城·法师塔", "age": "33"},
	{"name": "艾米", "map": "风岩城·宅邸", "age": "19"},
	{"name": "塞西莉亚", "map": "永恒王国", "age": "23"},
	{"name": "阿尔忒弥斯", "map": "永夜森林边缘", "age": "20"},
	{"name": "艾露恩", "map": "永夜森林深处", "age": "280"},
	{"name": "希尔薇", "map": "永夜森林边缘", "age": "150"},
	{"name": "塔玛拉", "map": "永夜森林边缘", "age": "45"},
	{"name": "罗兰", "map": "永恒王国", "age": "26"},
	{"name": "克莱尔", "map": "村外平原", "age": "25"},
	{"name": "凯瑟琳", "map": "金贸王国", "age": "21"},
	{"name": "琳达", "map": "永夜森林边缘", "age": "22"},
	{"name": "妮丝塔", "map": "无尽海·神秘岛屿", "age": "3000"},
]

func _ready() -> void:
	btn_back.pressed.connect(_on_back)
	_build_npc_cards()

func _build_npc_cards() -> void:
	for child in grid.get_children():
		child.queue_free()
	for npc: Dictionary in _core_npcs:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(140, 60)
		var vbox := VBoxContainer.new()
		var name_label := Label.new()
		name_label.text = npc["name"]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var info_label := Label.new()
		info_label.text = npc["map"] + " | " + npc["age"] + "岁"
		info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var btn := Button.new()
		btn.text = "查看对话"
		var npc_name: String = npc["name"]
		btn.pressed.connect(_on_npc_clicked.bind(npc_name))
		vbox.add_child(name_label)
		vbox.add_child(info_label)
		vbox.add_child(btn)
		card.add_child(vbox)
		grid.add_child(card)

func _on_npc_clicked(npc_name: String) -> void:
	# 用meta传递NPC名称
	var scene: PackedScene = load("res://scenes/RecallDialogue.tscn")
	if scene:
		var inst: Control = scene.instantiate()
		inst.set_meta("recall_npc", npc_name)
		get_tree().get_root().add_child(inst)
		get_tree().current_scene = inst
		hide()  # 隐藏而非销毁，让RecallDialogue可以返回
		# 通知RecallDialogue当前场景是RecallRoom
		inst.set_meta("caller_scene", self)

func _on_back() -> void:
	SceneManager.goto_scene("res://scenes/MainMenu.tscn")
