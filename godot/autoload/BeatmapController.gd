# res://autoload/BeatmapController.gd
extends Node

class NoteData:
	var time_ms: float
	var direction: int  # 0 = left (A), 1 = right (D)

var notes: Array = []
var map_info: Dictionary = {}

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
	
	for raw in data.get("inputs", []):
		var nd = NoteData.new()
		nd.time_ms = float(raw.get("time", 0))
		nd.direction = int(raw.get("direction", 0))
		notes.append(nd)

func get_notes() -> Array:
	return notes
