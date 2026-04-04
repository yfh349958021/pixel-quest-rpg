extends Node

signal scene_changed(scene_name: String)
var current_scene: Node = null

func change_scene(scene_path: String) -> void:
	var new_scene = load(scene_path).instantiate()
	if new_scene:
		if current_scene:
			current_scene.queue_free()
		await get_tree().process_frame
		get_tree().root.add_child(new_scene)
		current_scene = new_scene
		scene_changed.emit(scene_path)
