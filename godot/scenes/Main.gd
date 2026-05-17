# res://scenes/Main.gd
extends Node

@onready var note_spawner: Node = $Gameplay/NoteSpawner

func _ready() -> void:
	var file = FileAccess.open("res://maps/test.json", FileAccess.READ)
	if file == null:
		push_error("Harita bulunamadı!")
		return
	
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	
	var test_data = json.data
	
	BeatmapController.load_from_api(test_data)
	note_spawner.setup(BeatmapController.get_notes())
	SongManager.play()
	note_spawner._active = true
