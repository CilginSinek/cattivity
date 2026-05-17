# res://scenes/Main.gd
extends Node

@onready var note_spawner: Node = $Gameplay/NoteSpawner

func _ready() -> void:
	note_spawner.setup(BeatmapController.get_notes())
	note_spawner._active = true
