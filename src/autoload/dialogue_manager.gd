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
var current_portrait_path: String = ""
var current_talk_index: int = 0
var _audio_player: AudioStreamPlayer = null

func _ready() -> void:
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "DialogueAudioPlayer"
	add_child(_audio_player)

## 获取某个NPC当前可用的对话选项列表
func get_dialogue_options(npc_name: String) -> Array:
	var options: Array = []
	var max_talk: int = get_max_talk_count(npc_name)
	# 根据game_phase决定可选数量: phase >= talk_index 才可选
	var phase: int = GameManager.game_phase
	for i in range(1, max_talk + 1):
		if phase >= i:
			var talk_data: Array = _load_talk(npc_name, i)
			if talk_data.size() > 0:
				var label: String = "对话 " + str(i)
				# 尝试用第一句话做预览
				if talk_data.size() > 0:
					var first_text: String = talk_data[0].get("text", "")
					if first_text.length() > 10:
						label = first_text.substr(0, 10) + "..."
					elif first_text.length() > 0:
						label = first_text
				options.append({"index": i, "label": label})
	options.append({"index": -1, "label": "离开"})
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
	var cg_index: String = line.get("cg_index", "")
	var portrait_path: String = _get_portrait_path(current_npc_name, cg_index)
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

## 根据NPC名称和CG序号获取立绘路径
func _get_portrait_path(npc_name: String, cg_index: String) -> String:
	var base: String = npc_name + "_bigimage"
	# 优先尝试带CG序号的立绘: pianpian_bigimage_01
	if cg_index != "":
		var path: String = LocalizationManager.find_portrait(base + "_" + cg_index)
		if path != "":
			return path
	# 回退: NPC状态立绘
	var status: String = GameManager.get_npc_status(npc_name)
	if status != "default" and status != "":
		var path: String = LocalizationManager.find_portrait(base + "_" + status)
		if path != "":
			return path
	# 最终回退: 默认立绘
	return LocalizationManager.find_portrait(base + "_0")

func _play_dialogue_audio(line: Dictionary) -> void:
	_audio_player.stop()
	if line.has("audio_key"):
		var path: String = LocalizationManager.find_audio(line["audio_key"])
		if path != "":
			var stream: AudioStream = load(path) as AudioStream
			if stream:
				_audio_player.stream = stream
				_audio_player.play()

## 加载指定NPC的第N段对话
func _load_talk(npc_name: String, talk_index: int) -> Array:
	var file_path: String = _find_dialogue_file(npc_name)
	if file_path == "":
		return []
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return []
	var content: String = file.get_as_text()
	file.close()
	return _parse_dialogue(content, talk_index)

## 查找对话文件(当前语言优先,回退到中文)
func _find_dialogue_file(npc_name: String) -> String:
	var lang_suffix: String = SettingsManager.get_language_suffix()
	var fallback: String = "_cn" if lang_suffix == "_jp" else "_jp"
	for suf in [lang_suffix, fallback]:
		var fp: String = "res://data/dialogues/" + npc_name + "_talk" + suf + ".txt"
		if ResourceLoader.exists(fp):
			return fp
	return ""

## 解析对话内容
## 格式: {"name":"显示名",...,{{talk:1}{speaker_cgindex:"文本",...}}{{talk:2}{...}}}
func _parse_dialogue(content: String, talk_index: int) -> Array:
	var lines: Array = []
	var name_map: Dictionary = _extract_name_map(content)

	# 提取目标talk块: {{talk:N}{...}}
	var talk_pattern: RegEx = RegEx.new()
	talk_pattern.compile("\\{\\{talk\\s*:\\s*" + str(talk_index) + "\\}\\{(.*?)\\}\\}")
	var talk_match: RegExMatch = talk_pattern.search(content)
	if not talk_match:
		return []
	var block: String = talk_match.get_string(1).strip_edges()

	# 解析每行: speaker_cgindex:"文本" 或 speaker:"文本"
	var line_pattern: RegEx = RegEx.new()
	line_pattern.compile("([a-zA-Z_0-9]+?)(?:_(\\d+))?\\s*:\\s*\"([^\"]*)\"")
	var matches: Array = line_pattern.search_all(block)

	for m in matches:
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

## 提取名称映射表
## 格式: {"pianpian":"翩翩","actor":"勇者",...}
func _extract_name_map(content: String) -> Dictionary:
	var map: Dictionary = {}
	# 找到第一个 { 到第一个 {{talk 之间的内容
	var start: int = content.find("{")
	if start == -1:
		return map
	var end: int = content.find("{{talk")
	if end == -1:
		end = content.length()
	var header: String = content.substr(start, end - start)
	var pattern: RegEx = RegEx.new()
	pattern.compile("\"([a-zA-Z_0-9]+)\"\\s*:\\s*\"([^\"]*)\"")
	var matches: Array = pattern.search_all(header)
	for m in matches:
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
	var pattern: RegEx = RegEx.new()
	pattern.compile("\\{\\{talk\\s*:\\s*(\\d+)\\}\\}")
	var matches: Array = pattern.search_all(content)
	var max_talk: int = 0
	for m in matches:
		var idx: int = int(m.get_string(1))
		if idx > max_talk:
			max_talk = idx
	return max_talk
