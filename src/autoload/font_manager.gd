extends Node

var _default_font: FontFile
var _default_theme: Theme

func _ready():
	_default_font = load("res://assets/fonts/wqy-zenhei.ttc")
	if _default_font == null:
		push_error("字体加载失败！")
		return
	
	_default_theme = Theme.new()
	
	_default_theme.set_font("font", "Label", _default_font)
	_default_theme.set_font_size("font_size", "Label", 14)
	_default_theme.set_font("font", "Button", _default_font)
	_default_theme.set_font_size("font_size", "Button", 14)
	_default_theme.set_font("normal_font", "RichTextLabel", _default_font)
	_default_theme.set_font_size("normal_font_size", "RichTextLabel", 14)
	_default_theme.set_font("font", "LineEdit", _default_font)
	_default_theme.set_font_size("font_size", "LineEdit", 14)
	_default_theme.set_font("font", "PanelContainer", _default_font)
	_default_theme.set_font_size("font_size", "PanelContainer", 14)
	_default_theme.set_font("font", "HBoxContainer", _default_font)
	_default_theme.set_font("font", "VBoxContainer", _default_font)
	_default_theme.set_font("font", "ProgressBar", _default_font)
	_default_theme.set_font_size("font_size", "ProgressBar", 14)
	_default_theme.set_font("font", "ItemList", _default_font)
	_default_theme.set_font_size("font_size", "ItemList", 14)
	_default_theme.set_font("font", "OptionButton", _default_font)
	_default_theme.set_font_size("font_size", "OptionButton", 14)
	_default_theme.set_font("font", "CheckButton", _default_font)
	_default_theme.set_font_size("font_size", "CheckButton", 14)
	_default_theme.set_font("font", "SpinBox", _default_font)
	_default_theme.set_font_size("font_size", "SpinBox", 14)
	
	# 应用到场景树根节点 - 这会自动传播给所有子控件
	var root = get_tree().root
	root.theme = _default_theme
	
	# 递归应用到现有所有节点
	_apply_recursive(root)
	
	# 监听新添加的子节点
	root.child_entered_tree.connect(_on_child_added)

func _apply_recursive(node: Node):
	if node is Control:
		node.theme = _default_theme
	for c in node.get_children():
		_apply_recursive(c)

func _on_child_added(node: Node):
	# 延迟一帧确保节点完全初始化
	call_deferred("_apply_recursive", node)

func apply_to_label(label: Control):
	if _default_font:
		label.add_theme_font_override("font", _default_font)

func get_font() -> FontFile:
	return _default_font

func get_theme() -> Theme:
	return _default_theme
