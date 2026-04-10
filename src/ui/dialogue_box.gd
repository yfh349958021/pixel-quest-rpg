extends Control
## 对话框UI

@onready var portrait: TextureRect = $HBoxContainer/Portrait
@onready var speaker_label: Label = $HBoxContainer/VBox/SpeakerLabel
@onready var text_label: RichTextLabel = $HBoxContainer/VBox/TextLabel
@onready var option_container: VBoxContainer = $OptionsContainer
@onready var video_player: VideoStreamPlayer = $VideoPlayer

var _current_npc: Node = null
var _is_showing_options: bool = false

signal dialogue_finished

func _ready() -> void:
	hide()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line_shown.connect(_on_line_shown)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_video_requested.connect(_on_video_requested)

func show_for_npc(npc: Node) -> void:
	_current_npc = npc
	show()
	_show_dialogue_options()

func _show_dialogue_options() -> void:
	_is_showing_options = true
	option_container.show()
	text_label.text = ""
	speaker_label.text = ""
	portrait.texture = null

	for child in option_container.get_children():
		child.queue_free()

	var options: Array = DialogueManager.get_dialogue_options(_current_npc.get_npc_name())
	if options.is_empty():
		hide()
		_current_npc = null
		dialogue_finished.emit()
		return

	for opt in options:
		var btn: Button = Button.new()
		btn.text = opt["label"]
		var idx: int = opt["index"]
		btn.pressed.connect(_on_option_selected.bind(idx))
		option_container.add_child(btn)

func _on_option_selected(index: int) -> void:
	if index == -1:
		hide()
		_current_npc = null
		dialogue_finished.emit()
	else:
		_is_showing_options = false
		option_container.hide()
		DialogueManager.start_dialogue(_current_npc.get_npc_name(), index)

func _on_dialogue_started(_npc_name: String) -> void:
	show()

func _on_line_shown(speaker: String, text: String, portrait_path: String, _cg_index: String) -> void:
	speaker_label.text = speaker
	text_label.text = text
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		var tex: Texture2D = load(portrait_path) as Texture2D
		if tex:
			portrait.texture = tex
	else:
		portrait.texture = null

func _on_dialogue_ended() -> void:
	hide()
	_current_npc = null
	dialogue_finished.emit()

func _on_video_requested(video_path: String) -> void:
	if ResourceLoader.exists(video_path):
		video_player.stream = load(video_path) as VideoStream
		video_player.play()

func _input(event: InputEvent) -> void:
	if not visible or _is_showing_options:
		return
	if event.is_action_pressed("ui_accept"):
		DialogueManager.next_line()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("ui_cancel"):
		DialogueManager.end_dialogue()
		get_viewport().set_input_as_handled()
