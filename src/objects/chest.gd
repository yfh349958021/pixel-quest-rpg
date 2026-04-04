extends Node2D

@export var reward_items: Dictionary = {}
@export var dialog_lines: Array = ["你打开了一个箱子！"]
var is_open: bool = false
var anim_sprite: AnimatedSprite2D

func _ready() -> void:
	anim_sprite = get_node_or_null("AnimatedSprite2D")
	var interact = get_node_or_null("InteractableComponent")
	if interact:
		interact.interactable_activated.connect(_on_near)
		interact.interactable_deactivated.connect(_on_far)

func _on_near() -> void:
	pass

func _on_far() -> void:
	if is_open and anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("close"):
		anim_sprite.play("close")
		is_open = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_dialogue") and not is_open:
		var interact = get_node_or_null("InteractableComponent")
		if interact and interact.get("in_range"):
			is_open = true
			if anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("open"):
				anim_sprite.play("open")
			for item_name in reward_items:
				InventoryManager.add_collectable(item_name, reward_items[item_name])
			GameDialogueManager.show_dialogue.emit(dialog_lines)
