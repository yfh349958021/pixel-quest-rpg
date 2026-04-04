extends Node

var game_started: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu") and game_started:
		show_game_menu()

func start_game() -> void:
	game_started = true
	SceneManager.change_scene("res://scenes/FarmLevel.tscn")
	SaveGameManager.allow_save_game = true

func exit_game() -> void:
	get_tree().quit()

func show_game_menu() -> void:
	var menu = load("res://scenes/GameMenu.tscn").instantiate()
	get_tree().root.add_child(menu)
