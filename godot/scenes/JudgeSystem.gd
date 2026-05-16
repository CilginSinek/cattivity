# res://scenes/JudgeSystem.gd
extends Node

signal hit_result(score: int)
signal missed

# Timing pencereleri (ms cinsinden)
const PERFECT_WINDOW: float = 50.0   # ±50ms = tam puan
const GOOD_WINDOW: float = 100.0     # ±100ms = yarım puan
const BAD_WINDOW: float = 200.0      # ±200ms = az puan

# Puan değerleri
const PERFECT_SCORE: int = 300
const GOOD_SCORE: int = 100
const BAD_SCORE: int = 50

func judge(note_time_ms: float, note_direction: int, player_direction: int) -> void:
	# Yön yanlışsa direkt miss
	if note_direction != player_direction:
		emit_signal("missed")
		return
	
	var diff = abs(SongManager.song_time - note_time_ms)
	
	if diff <= PERFECT_WINDOW:
		emit_signal("hit_result", PERFECT_SCORE)
	elif diff <= GOOD_WINDOW:
		emit_signal("hit_result", GOOD_SCORE)
	elif diff <= BAD_WINDOW:
		emit_signal("hit_result", BAD_SCORE)
	else:
		emit_signal("missed")
