extends Node
## 对话管理器

signal dialogue_started(npc_name: String)
signal dialogue_line_shown(speaker: String, text: String, portrait_path: String)
signal dialogue_ended()
signal dialogue_video_requested(video_path: String)

var is_active: bool = false
var current_lines: Array = []
var current_line_index: int = 0
var current_npc_name: String = ""
var current_portrait_path: String = ""
var current_talk_index: int = 0
var _audio_player: AudioStreamPlayer = null

func _ready() -> void:
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "DialogueAudioPlayer"
	add_child(_audio_player)

func get_dialogue_options(npc_name: String) -> Array:
	var options: Array = []
	var phase: int = GameManager.game_phase
	for i in range(1, phase + 1):
		var talk_data: Array = _load_talk(npc_name, i)
		if talk_data.size() > 0:
			var label: String = LocalizationManager.get_text("dialogue_option") + " " + str(i)
			var first_text: String = talk_data[0].get("text", "")
			if first_text.length() > 0:
				label = first_text.substr(0, min(20, first_text.length())) + "..."
			options.append({"index": i, "label": label})
		else:
			break
	options.append({"index": -1, "label": LocalizationManager.get_text("leave")})
	return options

func start_dialogue(npc_name: String, talk_index: int) -> void:
	var lines: Array = _load_talk(npc_name, talk_index)
	if lines.size() == 0:
		dialogue_ended.emit()
		return
	is_active = true
	current_npc_name = npc_name
	current_talk_index = talk_index
	current_lines = lines
	current_line_index = 0
	dialogue_started.emit(npc_name)
	_show_current_line()

func _show_current_line() -> void:
	if current_line_index >= current_lines.size():
		end_dialogue()
		return
	var line: Dictionary = current_lines[current_line_index]
	var speaker: String = line.get("speaker", "")
	var text: String = line.get("text", "")
	_update_portrait(current_npc_name)
	_play_dialogue_audio(line)
	if line.has("video"):
		dialogue_video_requested.emit(line["video"])
	dialogue_line_shown.emit(speaker, text, current_portrait_path)

func next_line() -> void:
	if not is_active:
		return
	_audio_player.stop()
	current_line_index += 1
	if current_line_index >= current_lines.size():
		end_dialogue()
	else:
		_show_current_line()

func end_dialogue() -> void:
	is_active = false
	_audio_player.stop()
	current_lines.clear()
	current_line_index = 0
	dialogue_ended.emit()

func _update_portrait(npc_name: String) -> void:
	var status: String = GameManager.get_npc_status(npc_name)
	var base: String = npc_name + "_bigimage"
	if status != "default" and status != "":
		var path: String = LocalizationManager.find_portrait(base + "_" + status + "_0")
		if path != "":
			current_portrait_path = path
			return
	current_portrait_path = LocalizationManager.find_portrait(base + "_0")

func _play_dialogue_audio(line: Dictionary) -> void:
	_audio_player.stop()
	if line.has("audio_key"):
		var path: String = LocalizationManager.find_audio(line["audio_key"])
		if path != "":
			var stream: AudioStream = load(path) as AudioStream
			if stream:
				_audio_player.stream = stream
				_audio_player.play()

func _load_talk(npc_name: String, talk_index: int) -> Array:
	var file_path: String = ""
	var lang_suffix: String = SettingsManager.get_language_suffix()
	var suffixes: PackedStringArray = [lang_suffix, "_cn"]
	for suf in suffixes:
		var fp: String = "res://data/dialogues/" + npc_name + "_talk" + suf + ".txt"
		if ResourceLoader.exists(fp):
			file_path = fp
			break
	if file_path == "":
		return []
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return []
	var content: String = file.get_as_text()
	file.close()
	return _parse_dialogue(content, talk_index)

func _parse_dialogue(content: String, talk_index: int) -> Array:
	var lines: Array = []
	var pattern_str: String = "\\{\\{talk\\s*:\\s*" + str(talk_index) + "\\}\\{(.*?)\\}\\}"
	var regex: RegEx = RegEx.new()
	regex.compile(pattern_str)
	var result: RegExMatch = regex.search(content)
	if not result:
		return []
	var block: String = result.get_string(1).strip_edges()
	var name_map: Dictionary = _extract_name_map(content)
	var line_pattern: RegEx = RegEx.new()
	line_pattern.compile('([a-zA-Z_0-9]+)\\s*:\\s*"([^"]*)"')
	var matches: Array = line_pattern.search_all(block)
	for m in matches:
		var key: String = m.get_string(1)
		var text: String = m.get_string(2)
		var audio_key: String = key + "_talk" + str(talk_index) + "_" + str(lines.size())
		var speaker: String = name_map.get(key, key)
		lines.append({
			"speaker": speaker,
			"text": text,
			"audio_key": audio_key,
		})
	return lines

func _extract_name_map(content: String) -> Dictionary:
	var map: Dictionary = {}
	var start: int = content.find("{")
	if start == -1:
		return map
	var end: int = content.find("{{talk")
	if end == -1:
		end = content.length()
	var header: String = content.substr(start, end - start)
	var pattern: RegEx = RegEx.new()
	pattern.compile('"([a-zA-Z_0-9]+)"\\s*:\\s*"([^"]*)"')
	var matches: Array = pattern.search_all(header)
	for m in matches:
		map[m.get_string(1)] = m.get_string(2)
	return map

func get_max_talk_count(npc_name: String) -> int:
	var file_path: String = ""
	var lang_suffix: String = SettingsManager.get_language_suffix()
	var suffixes: PackedStringArray = [lang_suffix, "_cn"]
	for suf in suffixes:
		var fp: String = "res://data/dialogues/" + npc_name + "_talk" + suf + ".txt"
		if ResourceLoader.exists(fp):
			file_path = fp
			break
	if file_path == "":
		return 0
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return 0
	var content: String = file.get_as_text()
	file.close()
	var pattern: RegEx = RegEx.new()
	pattern.compile("\\{\\{talk\\s*:\\s*(\\d+)\\}\\}")
	var matches: Array = pattern.search_all(content)
	var max_talk: int = 0
	for m in matches:
		var idx: int = int(m.get_string(1))
		if idx > max_talk:
			max_talk = idx
	return max_talk
