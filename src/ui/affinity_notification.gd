extends CanvasLayer
## 好感度提升通知浮层

@onready var panel: PanelContainer = $Panel
@onready var npc_label: Label = $Panel/VBox/NPCName
@onready var level_label: Label = $Panel/VBox/LevelText
@onready var hint_label: Label = $Panel/VBox/Hint

var _is_showing: bool = false

func _ready() -> void:
	hide()
	AffinityManager.affinity_notification_requested.connect(_on_notification)

func _on_notification(npc_name: String, level: int) -> void:
	if _is_showing:
		return # 防止重复弹出
	_is_showing = true
	npc_label.text = npc_name
	var level_name: String = AffinityManager.get_affinity_name(npc_name)
	level_label.text = "好感度提升! Lv.%d「%s」" % [level, level_name]
	hint_label.text = "按空格键继续"
	# 动画弹出
	show()
	panel.modulate.a = 0.0
	panel.position.y = 50
	var tween: Tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel, "position:y", 0.0, 0.3)
	# 等待玩家按空格
	await _wait_for_dismiss()
	# 动画收起
	var tween2: Tween = create_tween()
	tween2.tween_property(panel, "modulate:a", 0.0, 0.2)
	tween2.tween_property(panel, "position:y", -30.0, 0.2)
	await tween2.finished
	hide()
	_is_showing = false

func _wait_for_dismiss() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
			break
