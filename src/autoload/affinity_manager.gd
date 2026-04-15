extends Node
## 好感度管理器 - 管理NPC好感度等级

const MAX_AFFINITY: int = 5

## 好感度等级名称
const LEVEL_NAMES: Array = [
	"",
	"路人",
	"略有好感",
	"好感加深",
	"亲密",
	"挚友",
]

signal affinity_changed(npc_name: String, old_level: int, new_level: int)
signal affinity_notification_requested(npc_name: String, level: int)

## npc_name -> affinity_level (0~MAX_AFFINITY)
var affinities: Dictionary = {}

func _ready() -> void:
	# 好感度数据在GameManager.save_data/load_save_data中持久化
	pass

## 对话结束后调用，提升好感度
func on_dialogue_finished(npc_name: String) -> void:
	if npc_name == "":
		return
	var old_level: int = get_affinity(npc_name)
	var new_level: int = mini(old_level + 1, MAX_AFFINITY)
	if new_level == old_level:
		return # 已满级
	affinities[npc_name] = new_level
	affinity_changed.emit(npc_name, old_level, new_level)
	# 发送通知
	affinity_notification_requested.emit(npc_name, new_level)

## 获取好感度等级
func get_affinity(npc_name: String) -> int:
	return affinities.get(npc_name, 0)

## 获取好感度等级名称
func get_affinity_name(npc_name: String) -> String:
	var level: int = get_affinity(npc_name)
	if level >= 0 and level < LEVEL_NAMES.size():
		return LEVEL_NAMES[level]
	return "未知"

## 是否达到指定等级
func has_affinity(npc_name: String, level: int) -> bool:
	return get_affinity(npc_name) >= level

## 获取所有好感度数据(存档用)
func get_save_data() -> Dictionary:
	return {"affinities": affinities.duplicate()}

## 从存档恢复
func load_save_data(data: Dictionary) -> void:
	affinities = data.get("affinities", {})

## 重置(新游戏)
func reset() -> void:
	affinities.clear()
