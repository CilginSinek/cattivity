# res://scenes/NoteSpawner.gd
extends Node

const CircleNote = preload("res://scenes/notes/CircleNote.tscn")
const SPAWN_AHEAD_MS: float = 1000.0

var _notes: Array = []
var _next_index: int = 0
var _active: bool = false

@onready var notes_container: Node = get_node("/root/main/Gameplay/GameplayWalls/Notes")	
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
	if _next_index >= _notes.size():
		return
	var next_note = _notes[_next_index]
	if SongManager.song_time >= next_note.time_ms - SPAWN_AHEAD_MS:
		_spawn_note(next_note)
		_next_index += 1

func _spawn_note(note_data) -> void:
	var instance = CircleNote.instantiate()
	instance.time_ms = note_data.time_ms
	instance.direction = note_data.direction
	var player = get_node("/root/main/Player")
	var gameplay = get_node("/root/main/Gameplay")
	instance.global_position = gameplay.to_global(Vector2(0.0, gameplay.to_local(player.global_position).y + Config.spawn_distance))
	notes_container.add_child(instance)

func _check_miss() -> void:
	for child in notes_container.get_children():
		if not child.has_method("get") or not "time_ms" in child:
			continue
		if SongManager.song_time > child.time_ms + 200.0 and not child.is_hit:
			judge_system.judge(child.time_ms, child.direction, -1)
			child.queue_free()

func _on_song_started() -> void:
	_active = true

func _on_song_ended() -> void:
	_active = false
