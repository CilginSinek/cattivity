# res://autoload/MapManager.gd
extends Node

signal maps_ready
signal download_progress(map_id: String, progress: float)

const MAPS_DIR = "user://maps/"
var maps_list: Array = []
var _http: HTTPRequest
var _download_queue: Array = []
var _current_download: Dictionary = {}

func _ready() -> void:
	_ensure_maps_dir()
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_download_complete)

func _ensure_maps_dir() -> void:
	if not DirAccess.dir_exists_absolute(MAPS_DIR):
		DirAccess.make_dir_absolute(MAPS_DIR)

func init_maps() -> void:
	maps_list.clear()
	var dir = DirAccess.open("res://maps/")
	if dir == null:
		push_error("MapManager: maps directory not found")
		emit_signal("maps_ready")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".zip"):
			var map_id = file_name.replace(".zip", "")
			maps_list.append({
				"_id": map_id,
				"name": map_id,
				"artist": "Unknown"
			})
		file_name = dir.get_next()
	dir.list_dir_end()
	emit_signal("maps_ready")

func _on_maps_list_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if response_code != 200:
		push_error("MapManager: maps list failed")
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	maps_list = json.data
	
	# Download missing zips
	_download_queue.clear()
	for map in maps_list:
		var zip_path = MAPS_DIR + map["_id"] + ".zip"
		if not FileAccess.file_exists(zip_path):
			_download_queue.append(map)
	
	if _download_queue.is_empty():
		emit_signal("maps_ready")
	else:
		_download_next()

func _download_next() -> void:
	if _download_queue.is_empty():
		emit_signal("maps_ready")
		return
	
	_current_download = _download_queue.pop_front()
	var headers = ["Authorization: " + Config.get_auth_header()]
	_http.request(Config.BASE_URL + "/maps/download/" + _current_download["_id"], headers)

func _on_download_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("MapManager: download failed for " + _current_download["_id"])
		_download_next()
		return
	
	var zip_path = MAPS_DIR + _current_download["_id"] + ".zip"
	var file = FileAccess.open(zip_path, FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	
	_download_next()

func get_maps() -> Array:
	return maps_list

func get_zip_path(map_id: String) -> String:
	return "res://maps/" + map_id + ".zip"
