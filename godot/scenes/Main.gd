# res://scenes/Main.gd
extends Node

@onready var note_spawner: Node = $Gameplay/NoteSpawner

func _ready() -> void:
	var test_data = {
		"name": "Test Map",
		"artist": "Test Artist",
		"bpm": 120,
		"offset": 0,
		"duration": 10000,
		"inputs": [
			{"time": 2000, "direction": 0},
			{"time": 4000, "direction": 1},
			{"time": 6000, "direction": 0},
			{"time": 8000, "direction": 1},
		]
	}
	
	BeatmapController.load_from_api(test_data)
	note_spawner.setup(BeatmapController.get_notes())
	SongManager.play()
	note_spawner._active = true
