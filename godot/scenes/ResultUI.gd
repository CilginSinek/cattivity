# res://scenes/ResultUI.gd
extends Control

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel

var _http: HTTPRequest

func _ready() -> void:
	visible = false
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_post_complete)
	
	GameStateManager.state_changed.connect(_on_state_changed)

func _on_state_changed(state: String) -> void:
	if state == "RESULT":
		show_result()

func show_result() -> void:
	var score_manager = get_node("/root/main/Gameplay/ScoreManager")
	var final = score_manager.get_final_score()
	
	score_label.text = "Score: %d" % final.score
	combo_label.text = "Max Combo: %d" % final.combo
	
	visible = true
	_post_score(final.score)

func _post_score(score: int) -> void:
	var map_id = BeatmapController.map_info.get("id", "")
	if map_id == "":
		return
	
	var body = JSON.stringify({"mapId": map_id, "score": score})
	var headers = ["Content-Type: application/json"]
	_http.request(
		Config.BASE_URL + "/play",
		headers,
		HTTPClient.METHOD_POST,
		body
	)

func _on_post_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 201:
		print("Score posted successfully")
	else:
		push_error("Score post failed: " + str(response_code))
