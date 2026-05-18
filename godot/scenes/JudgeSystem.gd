# res://scenes/JudgeSystem.gd
extends Node

signal hit_result(score: int, note_direction: int)
signal missed

# Timing windows (ms)
const PERFECT_WINDOW: float = 60.0   # ±60ms → inner ring = perfect
const GOOD_WINDOW: float = 130.0     # ±130ms → outer ring = good

# Skor değerleri
const PERFECT_SCORE: int = 300
const GOOD_SCORE: int = 150   # 100'den 150'ye yükseltildi

func judge(note_time_ms: float, note_direction: int, player_direction: int) -> void:
	# Yanlış yön → miss
	if note_direction != player_direction:
		emit_signal("missed")
		return

	var diff: float = abs(SongManager.song_time - note_time_ms)

	if diff <= PERFECT_WINDOW:
		emit_signal("hit_result", PERFECT_SCORE, note_direction)
	elif diff <= GOOD_WINDOW:
		emit_signal("hit_result", GOOD_SCORE, note_direction)
	else:
		emit_signal("missed")
