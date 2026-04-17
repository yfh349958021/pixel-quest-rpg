extends Node
## 对话管理器

signal dialogue_started(npc_name: String)
signal dialogue_line_shown(speaker: String, text: String, portrait_path: String, cg_index: String)
signal dialogue_ended()
signal dialogue_video_requested(video_path: String)

var is_active: bool = false
var current_lines: Array = []
var current_line_index: int = 0
var current_npc_name: String = ""
var current_npc_en_name: String = ""
var current_talk_index: int = 0
var _audio_player: AudioStreamPlayer = null

func _ready() -> void:
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "DialogueAudioPlayer"
	add_child(_audio_player)

func get_dialogue_options(npc_name: String) -> Array:
	push_warning("[DialogueManager] get_dialogue_options called with npc_name: ", npc_name)
	var _max_talk_dbg: int = get_max_talk_count(npc_name)
	push_warning("[DialogueManager] max_talk_count: ", _max_talk_dbg, ", game_phase: ", GameManager.game_phase)
	var options: Array = []
	var max_talk: int = get_max_talk_count(npc_name)
	var phase: int = GameManager.game_phase
	for i in range(1, max_talk + 1):
		if phase >= i:
			var talk_data: Array = load_talk(npc_name, i)
			if talk_data.size() > 0:
				var label: String = "对话 " + str(i)
				if talk_data.size() > 0:
					var first_text: String = talk_data[0].get("text", "")
					if first_text.length() > 10:
						label = first_text.substr(0, 10) + "..."
					elif first_text.length() > 0:
						label = first_text
				options.append({"index": i, "label": label})
			else:
				break
	options.append({"index": -1, "label": "离开"})
	return options

func start_dialogue(npc_name: String, talk_index: int) -> void:
	var lines: Array = load_talk(npc_name, talk_index)
	if lines.size() == 0:
		dialogue_ended.emit()
		return
	is_active = true
	current_npc_name = npc_name
	current_talk_index = talk_index
	current_lines = lines
	current_line_index = 0
	_extract_npc_en_name(npc_name)
	dialogue_started.emit(npc_name)
	_show_current_line()

## 公开方法: 加载某个NPC的某段对话(供recall_dialogue使用)
func load_talk(npc_name: String, talk_index: int) -> Array:
	var file_path: String = _find_dialogue_file(npc_name)
	if file_path == "":
		return []
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return []
	var content: String = file.get_as_text()
	file.close()
	return _parse_dialogue(content, talk_index)

func _extract_npc_en_name(npc_name: String) -> void:
	var file_path: String = _find_dialogue_file(npc_name)
	if file_path == "":
		current_npc_en_name = npc_name
		return
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		current_npc_en_name = npc_name
		return
	var first_line: String = file.get_line()
	file.close()
	var pattern: RegEx = RegEx.new()
	pattern.compile('"([a-zA-Z_0-9]+)":"[^"]*"')
	var m: RegExMatch = pattern.search(first_line)
	if m:
		current_npc_en_name = m.get_string(1)
	else:
		current_npc_en_name = npc_name

func _show_current_line() -> void:
	if current_line_index >= current_lines.size():
		end_dialogue()
		return
	var line: Dictionary = current_lines[current_line_index]
	var speaker: String = line.get("speaker", "")
	var text: String = line.get("text", "")
	var cg_index: String = line.get("cg_index", "")
	var speaker_key: String = line.get("speaker_key", "")
	var portrait_path: String = _get_portrait_path(speaker_key, cg_index)
	_play_dialogue_audio(line)
	if line.has("video"):
		dialogue_video_requested.emit(line["video"])
	dialogue_line_shown.emit(speaker, text, portrait_path, cg_index)

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

func _get_portrait_path(speaker_key: String, cg_index: String) -> String:
	if speaker_key == "" or speaker_key == "actor":
		return ""
	var npc_name: String = current_npc_name
	if npc_name == "":
		npc_name = speaker_key
	var expr_id: String = cg_index if cg_index != "" else "01"
	return LocalizationManager.find_portrait(npc_name, expr_id)

func _play_dialogue_audio(line: Dictionary) -> void:
	_audio_player.stop()
	if line.has("audio_key"):
		var path: String = LocalizationManager.find_audio(line["audio_key"])
		if path != "":
			var stream: AudioStream = load(path) as AudioStream
			if stream:
				_audio_player.stream = stream
				_audio_player.play()

func _find_dialogue_file(npc_name: String) -> String:
	var lang_suffix: String = SettingsManager.get_language_suffix()
	var fallback: String = "_jp" if lang_suffix == "_cn" else "_cn"
	for suf in [lang_suffix, fallback]:
		var fp: String = "res://data/npc_dialogues/" + npc_name + "_talk" + suf + ".txt"
		if FileAccess.file_exists(fp):
			return fp
	return ""

func _parse_dialogue(content: String, talk_index: int) -> Array:
	var lines: Array = []
	var name_map: Dictionary = _extract_name_map(content)
	# 匹配格式: {talk:N}{对话内容}  或  {{talk:N}{对话内容}
	var talk_pattern: RegEx = RegEx.new()
	talk_pattern.compile("\\{talk\\s*:\\s*" + str(talk_index) + "\\}\\{(.*?)\\}(?=,\\{talk:|\\}\\})")
	var talk_match: RegExMatch = talk_pattern.search(content)
	if not talk_match:
		return []
	var block: String = talk_match.get_string(1).strip_edges()
	var line_pattern: RegEx = RegEx.new()
	line_pattern.compile("([a-zA-Z_0-9]+?)(?:_(\\d+))?\\s*:\\s*\"([^\"]*)\"")
	var matches: Array = line_pattern.search_all(block)
	for m: RegExMatch in matches:
		var raw_speaker: String = m.get_string(1)
		var cg_index: String = m.get_string(2) if m.get_string(2) != "" else ""
		var text: String = m.get_string(3)
		var display_name: String = name_map.get(raw_speaker, raw_speaker)
		var audio_key: String = raw_speaker + "_talk" + str(talk_index) + "_" + str(lines.size())
		lines.append({
			"speaker": display_name,
			"speaker_key": raw_speaker,
			"text": text,
			"cg_index": cg_index,
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
	for m: RegExMatch in matches:
		map[m.get_string(1)] = m.get_string(2)
	return map

func get_max_talk_count(npc_name: String) -> int:
	var file_path: String = _find_dialogue_file(npc_name)
	if file_path == "":
		return 0
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return 0
	var content: String = file.get_as_text()
	file.close()
	push_warning("[DialogueManager] get_max_talk_count for: ", npc_name, " file_path: ", file_path)
	var pattern: RegEx = RegEx.new()
	pattern.compile("\\{talk\\s*:\\s*(\\d+)\\}\\{")
	var matches: Array = pattern.search_all(content)
	var max_talk: int = 0
	for m: RegExMatch in matches:
		var idx: int = int(m.get_string(1))
		if idx > max_talk:
			max_talk = idx
	return max_talk
