# res://scenes/NoteSpawner.gd
extends Node

const SPAWN_AHEAD_MS: float = 3000.0

var _notes: Array = []
var _next_index: int = 0
var _active: bool = false
var _active_notes: Array = []
var _start_pos: Vector2 = Vector2.ZERO
var _path_points: Array = []

const CircleNote = preload("res://scenes/notes/CircleNote.tscn")

func _ready() -> void:
	SongManager.song_started.connect(_on_song_started)
	SongManager.song_ended.connect(_on_song_ended)

func setup(notes: Array, start_pos: Vector2 = Vector2.ZERO) -> void:
	_notes = notes
	_next_index = 0
	_active_notes.clear()
	_start_pos = start_pos
	
	var generator = get_node_or_null("../WallGenerator")
	if generator and generator.has_method("calculate_path"):
		var duration = float(BeatmapController.map_info.get("duration", 0)) if BeatmapController.map_info.has("duration") else 100000.0
		_path_points = generator.calculate_path(notes, duration, start_pos)

func _process(_delta: float) -> void:
	if not _active:
		return
	_check_spawn()
	_check_miss()

func _check_spawn() -> void:
	while _next_index < _notes.size():
		var note = _notes[_next_index]
		if SongManager.song_time >= note.time_ms - SPAWN_AHEAD_MS:
			_spawn_ring(note, _next_index)
			_next_index += 1
		else:
			break

func _spawn_ring(note_data, note_idx: int) -> void:
	var instance = CircleNote.instantiate()
	instance.time_ms  = note_data.time_ms
	instance.direction = note_data.direction

	# Ring'in pozisyonu path_points üzerindeki nota noktasına eşittir
	if note_idx + 1 < _path_points.size():
		instance.position = _path_points[note_idx + 1]
	else:
		instance.position = Vector2(_start_pos.x, note_data.time_ms * Config.PIXELS_PER_MS)

	# WorldContainer altına ekle (Node2D hierarchy doğru olsun)
	get_parent().add_child(instance)
	_active_notes.append(instance)
	instance.tree_exiting.connect(func(): _active_notes.erase(instance))

func _check_miss() -> void:
	const MISS_WINDOW: float = 200.0
	for note_node in _active_notes.duplicate():
		if note_node == null or not is_instance_valid(note_node):
			_active_notes.erase(note_node)
			continue
		if note_node.is_hit:
			continue
		if SongManager.song_time > note_node.time_ms + MISS_WINDOW:
			note_node.is_hit = true
			note_node.queue_free()
			var judge = get_node_or_null("/root/main/GameplayInput/JudgeSystem")
			if judge:
				judge.emit_signal("missed")

func get_active_notes() -> Array:
	var valid: Array = []
	for n in _active_notes:
		if is_instance_valid(n) and not n.is_hit:
			valid.append(n)
	valid.sort_custom(func(a, b): return a.time_ms < b.time_ms)
	return valid

func _on_song_started() -> void:
	_active = true

func _on_song_ended() -> void:
	_active = false
