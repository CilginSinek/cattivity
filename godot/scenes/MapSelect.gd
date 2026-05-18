# res://scenes/MapSelect.gd
extends Control

@onready var map_list: VBoxContainer = $MarginContainer/VBox/ScrollContainer/VBoxContainer
@onready var status_label: Label = $MarginContainer/VBox/StatusLabel
@onready var prev_button: Button = $MarginContainer/VBox/PaginationContainer/PrevButton
@onready var next_button: Button = $MarginContainer/VBox/PaginationContainer/NextButton
@onready var page_label: Label = $MarginContainer/VBox/PaginationContainer/PageLabel
@onready var back_button: Button = $MarginContainer/VBox/HeaderBox/BackButton

var _current_page: int = 1

func _ready() -> void:
	MapManager.maps_ready.connect(_on_maps_ready)
	MapManager.maps_error.connect(_on_maps_error)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	back_button.pressed.connect(_on_back_pressed)
	_load_page(1)

func _load_page(page: int) -> void:
	_current_page = page
	status_label.text = "Haritalar yükleniyor..."
	prev_button.disabled = true
	next_button.disabled = true

	# Mevcut kartları temizle
	for child in map_list.get_children():
		child.queue_free()

	MapManager.init_maps(page)

func _on_maps_ready() -> void:
	var maps = MapManager.get_maps()
	status_label.text = ""

	if maps.is_empty():
		status_label.text = "Hiç harita bulunamadı."
		prev_button.disabled = _current_page <= 1
		next_button.disabled = true
		page_label.text = "Sayfa %d" % _current_page
		return

	for map in maps:
		var card = _create_map_card(map)
		map_list.add_child(card)

	prev_button.disabled = _current_page <= 1
	next_button.disabled = maps.size() < 10  # 10'dan az geldiyse son sayfa
	page_label.text = "Sayfa %d" % _current_page

func _on_maps_error(message: String) -> void:
	status_label.text = "Hata: " + message

func _create_map_card(map: Dictionary) -> Control:
	var panel = PanelContainer.new()

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	# Sol: bilgiler
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var name_label = Label.new()
	name_label.text = map.get("name", "Bilinmeyen")
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	var sub_label = Label.new()
	sub_label.text = map.get("artist", "?") + " · " + map.get("difficulty", "Normal")
	sub_label.modulate = Color(0.75, 0.75, 0.75)
	vbox.add_child(sub_label)

	# Kullanıcıya ait skor bilgileri
	var user_max = map.get("userMaxScore", null)
	var user_rank = map.get("userRank", null)
	if user_max != null or user_rank != null:
		var score_label = Label.new()
		var score_text = ""
		if user_max != null:
			score_text += "Max Skor: %d" % int(user_max)
		if user_rank != null:
			if score_text != "":
				score_text += "  |  "
			score_text += "Sıra: #%d" % int(user_rank)
		score_label.text = score_text
		score_label.modulate = Color(0.9, 0.8, 0.4)
		vbox.add_child(score_label)

	# Sağ: oyna butonu
	var btn = Button.new()
	btn.text = "OYNA"
	btn.custom_minimum_size = Vector2(80, 0)
	btn.pressed.connect(_on_map_selected.bind(map))
	hbox.add_child(btn)

	return panel

func _on_map_selected(map: Dictionary) -> void:
	BeatmapController.selected_map = map
	GameStateManager.start_game()

func _on_prev_pressed() -> void:
	if _current_page > 1:
		_load_page(_current_page - 1)

func _on_next_pressed() -> void:
	_load_page(_current_page + 1)

func _on_back_pressed() -> void:
	GameStateManager.go_to_menu()
