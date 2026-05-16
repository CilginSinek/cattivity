# res://scenes/NoteSpawner.gd
extends Node

const CircleNote = preload("res://scenes/notes/CircleNote.tscn")

var _notes: Array = []
var _next_index: int = 0
var _active: bool = false

@onready var notes_container: Node = get_node("/root/main/Gameplay/Notes")

func _ready() -> void:
	SongManager.song_started.connect(_on_song_started)
	SongManager.song_ended.connect(_on_song_ended)

func _process(_delta: float) -> void:
	if not _active:
		return
	_check_spawn()

func setup(notes: Array) -> void:
	_notes = notes
	_next_index = 0

func _check_spawn() -> void:
	if _next_index >= _notes.size():
		return
	
	var next_note = _notes[_next_index]
	# 1000ms önce spawn et ki ekrana gelsin
	if SongManager.song_time >= next_note.time_ms - 1000.0:
		_spawn_note(next_note)
		_next_index += 1

func _spawn_note(note_data) -> void:
	var instance = CircleNote.instantiate()
	instance.position = note_data.position
	instance.time_ms = note_data.time_ms
	notes_container.add_child(instance)
	
	# JudgeSystem'e bağla
	var judge = get_node("/root/main/Gameplay/JudgeSystem")
	instance.hit.connect(judge.judge_hit)

func _on_song_started() -> void:
	_active = true

func _on_song_ended() -> void:
	_active = false
