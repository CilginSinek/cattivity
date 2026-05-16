# res://scenes/ScoreManager.gd
extends Node

signal score_updated(score: int)
signal combo_changed(combo: int)

var score: int = 0
var combo: int = 0
var max_combo: int = 0

# Streak çarpan tablosu
# combo 0-9 → x1, 10-19 → x2, 20-29 → x4, 30+ → x8
func _get_multiplier() -> int:
	if combo >= 30:
		return 8
	elif combo >= 20:
		return 4
	elif combo >= 10:
		return 2
	else:
		return 1

func add_hit(base_score: int) -> void:
	combo += 1
	if combo > max_combo:
		max_combo = combo
	
	var multiplier = _get_multiplier()
	score += base_score * multiplier
	
	emit_signal("score_updated", score)
	emit_signal("combo_changed", combo)

func add_miss() -> void:
	combo = 0
	emit_signal("combo_changed", combo)

func reset() -> void:
	score = 0
	combo = 0
	max_combo = 0
	emit_signal("score_updated", score)
	emit_signal("combo_changed", combo)

func get_final_score() -> Dictionary:
	return {
		"score": score,
		"combo": max_combo
	}
