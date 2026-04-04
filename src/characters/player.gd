class_name Player
extends CharacterBody2D

@export var speed: int = 80
var player_direction: Vector2 = Vector2.DOWN
var current_tool: DataTypes.Tools = DataTypes.Tools.None

var anim_sprite: AnimatedSprite2D
var state_machine: NodeStateMachine

func _ready() -> void:
	add_to_group("player")
	anim_sprite = get_node_or_null("AnimatedSprite2D")
	state_machine = get_node_or_null("StateMachine")
	ToolManager.tool_selected.connect(on_tool_selected)

func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine._physics_process(delta)
