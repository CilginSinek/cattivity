# res://scenes/gameplay.gd
# Input yönetimi: A/D → JudgeSystem → miss ise direkt oyun biter
extends Node2D

@onready var judge_system: Node = $JudgeSystem
@onready var score_manager: Node = $ScoreManager

func _ready() -> void:
	judge_system.hit_result.connect(_on_hit_result)
	judge_system.missed.connect(_on_missed)

func _on_hit_result(score: int, note_direction: int) -> void:
	score_manager.add_hit(score)
	var main = get_node_or_null("/root/main")
	if main and main.has_method("turn_player"):
		main.turn_player(note_direction)

func _on_missed() -> void:
	# 1 miss = oyun biter
	SongManager.stop()
	GameStateManager.end_game()

func _process(_delta: float) -> void:
	if not SongManager.is_playing:
		return
	_handle_input()

func _handle_input() -> void:
	if Input.is_action_just_pressed("rotate_left"):
		_check_note_hit(0)
	if Input.is_action_just_pressed("rotate_right"):
		_check_note_hit(1)
	if Input.is_action_just_pressed("ui_cancel"):
		SongManager.stop()
		GameStateManager.go_to_map_select()

func _check_note_hit(player_direction: int) -> void:
	# Aktif ring'leri NoteSpawner'dan al
	var spawner = get_node_or_null("/root/main/WorldContainer/NoteSpawner")
	if spawner == null:
		return
	var active = spawner.get_active_notes()
	if active.is_empty():
		# Hiç aktif ring yok ama tuş basıldı — boşa basış, miss değil
		return
	# En yakın (en eski) notu judge et
	var note = active[0]
	if note.is_hit:
		return
		
	judge_system.judge(note.time_ms, note.direction, player_direction)
	
	# Nota işlendiği için işaretleyip sahneden kaldırıyoruz
	# Böylece NoteSpawner timeout olup "missed" göndermez
	note.is_hit = true
	note.queue_free()
