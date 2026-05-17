# res://scenes/MapSelect.gd
extends Control

@onready var map_list: VBoxContainer = $ScrollContainer/VBoxContainer

func _ready() -> void:
	MapManager.maps_ready.connect(_on_maps_ready)
	MapManager.init_maps()

func _on_maps_ready() -> void:
	for map in MapManager.get_maps():
		var button = Button.new()
		button.text = map.get("name", "Unknown") + " - " + map.get("artist", "Unknown")
		button.pressed.connect(_on_map_selected.bind(map))
		map_list.add_child(button)

func _on_map_selected(map: Dictionary) -> void:
	BeatmapController.current_map = map
	SongManager.load_and_play_local(MapManager.get_zip_path(map["_id"]))
	GameStateManager.start_game()
