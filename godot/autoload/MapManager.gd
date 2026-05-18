# res://autoload/MapManager.gd
extends Node

signal maps_ready
signal maps_error(message: String)

var maps_list: Array = []
var _http: HTTPRequest

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_response)

func init_maps(page: int = 1) -> void:
	maps_list.clear()
	var headers = ["Authorization: " + Config.get_auth_header()]
	var url = Config.BASE_URL + "/maps?page=" + str(page)
	var err = _http.request(url, headers)
	if err != OK:
		push_error("MapManager: HTTP request failed: " + str(err))
		emit_signal("maps_ready")

func _on_response(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("MapManager: server returned " + str(response_code))
		emit_signal("maps_error", "Sunucudan harita listesi alınamadı (%d)" % response_code)
		emit_signal("maps_ready")
		return

	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		push_error("MapManager: JSON parse failed")
		emit_signal("maps_error", "JSON ayrıştırma hatası")
		emit_signal("maps_ready")
		return

	var data = json.data
	if typeof(data) == TYPE_ARRAY:
		maps_list = data
	else:
		maps_list = []
		push_error("MapManager: expected Array, got: " + str(typeof(data)))

	emit_signal("maps_ready")

func get_maps() -> Array:
	return maps_list
