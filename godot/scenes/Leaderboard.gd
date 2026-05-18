# res://scenes/Leaderboard.gd
extends Control

@onready var user_list: VBoxContainer = $MarginContainer/VBox/ScrollContainer/UserList
@onready var status_label: Label = $MarginContainer/VBox/StatusLabel
@onready var prev_button: Button = $MarginContainer/VBox/PaginationContainer/PrevButton
@onready var next_button: Button = $MarginContainer/VBox/PaginationContainer/NextButton
@onready var page_label: Label = $MarginContainer/VBox/PaginationContainer/PageLabel
@onready var back_button: Button = $MarginContainer/VBox/HeaderBox/BackButton

var _current_page: int = 1
var _max_page: int = 1
var _http: HTTPRequest

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	
	_load_page(1)

func _load_page(page: int) -> void:
	_current_page = page
	status_label.text = "Liderlik tablosu yükleniyor..."
	prev_button.disabled = true
	next_button.disabled = true
	
	for child in user_list.get_children():
		child.queue_free()
		
	var url = Config.BASE_URL + "/leaderboard?page=" + str(page)
	var headers = [
		"Authorization: " + Config.get_auth_header(),
		"Content-Type: application/json"
	]
	var err = _http.request(url, headers)
	if err != OK:
		status_label.text = "Bağlantı hatası!"
		
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		status_label.text = "Sunucu hatası: " + str(response_code)
		return
		
	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		status_label.text = "Veri okunamadı!"
		return
		
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		status_label.text = "Geçersiz veri formatı!"
		return
		
	var users = data.get("users", [])
	_max_page = data.get("maxPage", 1)
	if _max_page < 1:
		_max_page = 1
		
	status_label.text = ""
	
	if users.is_empty():
		status_label.text = "Kayıtlı kullanıcı yok."
	else:
		for i in range(users.size()):
			var u = users[i]
			var rank = (_current_page - 1) * 10 + i + 1
			var card = _create_user_card(rank, u)
			user_list.add_child(card)
			
	page_label.text = "Sayfa " + str(_current_page)
	prev_button.disabled = (_current_page <= 1)
	next_button.disabled = (_current_page >= _max_page)

func _create_user_card(rank: int, user: Dictionary) -> Control:
	var panel = PanelContainer.new()
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)
	
	var rank_label = Label.new()
	rank_label.text = "#" + str(rank)
	rank_label.custom_minimum_size = Vector2(50, 0)
	rank_label.add_theme_font_size_override("font_size", 20)
	rank_label.modulate = Color(0.9, 0.8, 0.4)
	hbox.add_child(rank_label)
	
	var name_label = Label.new()
	name_label.text = user.get("name", "Bilinmeyen")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(name_label)
	
	var score_label = Label.new()
	var total_score = user.get("totalScore", 0)
	if total_score == null:
		total_score = 0
	score_label.text = "Skor: " + str(total_score)
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.modulate = Color(0.6, 0.9, 0.6)
	hbox.add_child(score_label)
	
	return panel

func _on_prev_pressed() -> void:
	if _current_page > 1:
		_load_page(_current_page - 1)

func _on_next_pressed() -> void:
	if _current_page < _max_page:
		_load_page(_current_page + 1)

func _on_back_pressed() -> void:
	GameStateManager.go_to_menu()
