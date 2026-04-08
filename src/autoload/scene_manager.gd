extends Node
## 场景管理器

var _transition_rect: ColorRect = null
var _is_transitioning: bool = false

func _ready() -> void:
	_transition_rect = ColorRect.new()
	_transition_rect.color = Color.BLACK
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_rect.z_index = 100
	_transition_rect.modulate.a = 0.0
	add_child(_transition_rect)

func goto_scene(path: String, fade_duration: float = 0.5) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	await _fade_to_black(fade_duration)
	get_tree().change_scene_to_file(path)
	await _fade_from_black(fade_duration)
	_is_transitioning = false

func _fade_to_black(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_transition_rect, "modulate:a", 1.0, duration)
	await tween.finished

func _fade_from_black(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_transition_rect, "modulate:a", 0.0, duration)
	await tween.finished
