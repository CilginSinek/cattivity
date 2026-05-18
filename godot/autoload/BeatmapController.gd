# res://autoload/BeatmapController.gd
extends Node

class NoteData:
	var time_ms: float
	var direction: int  # 0 = sol (A), 1 = sağ (D)

var notes: Array = []
var map_info: Dictionary = {}
var selected_map: Dictionary = {}  # server'dan gelen tam map objesi (audioUrl, fileUrl dahil)

var _http: HTTPRequest

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)

func load_from_api(data: Dictionary) -> void:
	notes.clear()
	map_info = {
		"name": data.get("name", ""),
		"artist": data.get("artist", ""),
		"bpm": data.get("bpm", 120),
		"offset": data.get("offset", 0),
		"duration": data.get("duration", 0),
	}

	SongManager.set_offset(float(data.get("offset", 0)))
	SongManager.set_duration(float(data.get("duration", 0)))

	for raw in data.get("inputs", []):
		var nd = NoteData.new()
		nd.time_ms = float(raw.get("time", 0))
		nd.direction = int(raw.get("direction", 0))
		notes.append(nd)

func load_from_web(on_done: Callable) -> void:
	var file_url = selected_map.get("fileUrl", "")
	if file_url == "":
		push_error("BeatmapController: selected_map.fileUrl boş")
		return

	var full_url = Config.BASE_URL + file_url
	var headers = ["Authorization: " + Config.get_auth_header()]
	_http.request_completed.connect(_on_json_received.bind(on_done), CONNECT_ONE_SHOT)
	var err = _http.request(full_url, headers)
	if err != OK:
		push_error("BeatmapController: JSON request hatası: " + str(err))

func _on_json_received(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, on_done: Callable) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("BeatmapController: JSON fetch başarısız: " + str(response_code))
		return

	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		push_error("BeatmapController: JSON parse hatası")
		return

	load_from_api(json.data)
	on_done.call()

func get_notes() -> Array:
	return notes
