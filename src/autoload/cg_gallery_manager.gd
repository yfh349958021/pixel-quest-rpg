extends Node
## CG画廊管理器

signal cg_unlocked(cg_id: String)
signal secret_code_entered()

# CG列表 (文件路径)
var _all_cgs: Array = []
# 已解锁的CG ID
var unlocked_cgs: Array = []

# 秘籍计数
var _right_count: int = 0
var _left_count: int = 0
var _secret_unlocked: bool = false

signal gallery_updated()

func _ready() -> void:
	# 扫描CG文件
	_scan_cg_files()
	# 从GameManager加载已解锁的CG
	unlocked_cgs = GameManager.unlocked_cgs.duplicate()

func _scan_cg_files() -> void:
	_all_cgs.clear()
	var dir := DirAccess.open("res://assets/sprites/cg/")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".import"):
				var cg_name := file_name.replace(".import", "")
				_all_cgs.append(cg_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func get_all_cgs() -> Array:
	return _all_cgs

func get_unlocked_cgs() -> Array:
	return unlocked_cgs

func is_cg_unlocked(cg_id: String) -> bool:
	return cg_id in unlocked_cgs

func unlock_cg(cg_id: String) -> void:
	if cg_id not in unlocked_cgs:
		unlocked_cgs.append(cg_id)
		GameManager.unlock_cg(cg_id)
		cg_unlocked.emit(cg_id)
		gallery_updated.emit()

## 秘籍输入: 右箭头
func input_right() -> void:
	_right_count += 1
	_check_secret()

## 秘籍输入: 左箭头
func input_left() -> void:
	_left_count += 1
	_check_secret()

func _check_secret() -> void:
	# 右3次 + 左6次 = 解锁全部
	if _right_count >= 3 and _left_count >= 6 and not _secret_unlocked:
		_secret_unlocked = true
		_unlock_all_cgs()
		secret_code_entered.emit()

func _unlock_all_cgs() -> void:
	for cg in _all_cgs:
		if cg not in unlocked_cgs:
			unlocked_cgs.append(cg)
			GameManager.unlock_cg(cg)
	gallery_updated.emit()

func reset_counter() -> void:
	_right_count = 0
	_left_count = 0
