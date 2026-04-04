class_name NPC
extends CharacterBody2D

@export var npc_name: String = "村民"
@export var dialog_lines: Array = ["你好！"]
@export var min_walk: int = 2
@export var max_walk: int = 5

var walk_cycles: int = 0
var current_walk_cycle: int = 0
var anim_sprite: AnimatedSprite2D
var state_machine: NodeStateMachine
var in_range: bool = false

func _ready() -> void:
	anim_sprite = get_node_or_null("AnimatedSprite2D")
	state_machine = get_node_or_null("StateMachine")
	var interact = get_node_or_null("InteractableComponent")
	if interact:
		interact.interactable_activated.connect(_on_player_near)
		interact.interactable_deactivated.connect(_on_player_left)

func _on_player_near() -> void:
	in_range = true

func _on_player_left() -> void:
	in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if in_range and event.is_action_pressed("show_dialogue"):
		GameDialogueManager.show_dialogue.emit(dialog_lines)
