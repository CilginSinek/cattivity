# res://scenes/NoteSpawner.gd
extends Node

const CircleNote = preload("res://scenes/notes/CircleNote.tscn")

const SPAWN_AHEAD_MS: float = 1000.0

var _notes: Array = []
var _next_index: int = 0
var _active: bool = false

@onready var notes_container: Node = get_node("/root/main/Notes")
@onready var judge_system: Node = get_node("/root/main/Gameplay/JudgeSystem")

func _ready() -> void:
	SongManager.song_started.connect(_on_song_started)
	SongManager.song_ended.connect(_on_song_ended)

func _process(_delta: float) -> void:
	if not _active:
		return
	_check_spawn()
	_check_miss()

func setup(notes: Array) -> void:
	_notes = notes
	_next_index = 0

func _check_spawn() -> void:
	print("check: ", _next_index, "/", _notes.size(), " time: ", SongManager.song_time)
	if _next_index >= _notes.size():
		return
	var next_note = _notes[_next_index]
	if SongManager.song_time >= next_note.time_ms - SPAWN_AHEAD_MS:
		_spawn_note(next_note)
		_next_index += 1

var _last_x: float = 0.0
var _note_count: int = 0

func _spawn_note(note_data) -> void:
	var instance = CircleNote.instantiate()
	instance.time_ms = note_data.time_ms
	instance.direction = note_data.direction
	var player = get_node("/root/main/Player")
	
	# Açısal dağılım — 3'lü döngü
	var x_positions = [0.0, -200.0, 200.0]
	var x_offset = x_positions[_note_count % 3]
	_note_count += 1
	
	instance.global_position = Vector2(x_offset, player.global_position.y + Config.spawn_distance)
	notes_container.add_child(instance)

func _check_miss() -> void:
	for child in notes_container.get_children():
		if SongManager.song_time > child.time_ms + 200.0 and not child.is_hit:
			judge_system.judge(child.time_ms, child.direction, -1)
			child.queue_free()

func _on_song_started() -> void:
	_active = true

func _on_song_ended() -> void:
	_active = false
