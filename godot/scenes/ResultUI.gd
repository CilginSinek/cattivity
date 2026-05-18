# res://scenes/ResultUI.gd
extends Control

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var back_button: Button = $BackButton
@onready var restart_button: Button = $RestartButton

var _http: HTTPRequest

func _ready() -> void:
	visible = false
	back_button.pressed.connect(_on_back_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_post_complete)

	GameStateManager.state_changed.connect(_on_state_changed)

func _on_state_changed(state: String) -> void:
	if state == "RESULT":
		show_result()

func show_result() -> void:
	var score_manager = get_node_or_null("/root/main/GameplayInput/ScoreManager")
	if score_manager == null:
		visible = true
		return

	var final = score_manager.get_final_score()
	score_label.text = "Skor: %d" % final.score
	combo_label.text = "Max Kombo: %d" % final.combo

	# Kullanıcının bu haritadaki önceki max skoru
	var prev_max = BeatmapController.selected_map.get("userMaxScore", null)
	if prev_max != null:
		combo_label.text += "\nÖnceki Max Skor: %d" % int(prev_max)

	visible = true
	_post_score(final.score)

func _post_score(score: int) -> void:
	var map_id = BeatmapController.selected_map.get("_id", "")
	if map_id == "":
		push_error("ResultUI: map_id boş, skor gönderilemez")
		return

	var body = JSON.stringify({"mapId": map_id, "score": score})
	var headers = [
		"Content-Type: application/json",
		"Authorization: " + Config.get_auth_header()
	]
	var err = _http.request(
		Config.BASE_URL + "/game/play",
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	if err != OK:
		push_error("ResultUI: POST isteği başarısız: " + str(err))

func _on_post_complete(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code == 201:
		print("ResultUI: skor başarıyla kaydedildi")
	else:
		push_error("ResultUI: skor kaydetme başarısız, kod: " + str(response_code))

func _on_back_pressed() -> void:
	SongManager.stop()
	GameStateManager.go_to_map_select()

func _on_restart_pressed() -> void:
	SongManager.stop()
	get_tree().reload_current_scene()
