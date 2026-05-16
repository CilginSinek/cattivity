# res://scenes/JudgeSystem.gd
extends Node

signal hit_result(ring_index: int, score: int)
signal missed

# Ring'e göre base puan
const RING_SCORES: Array[int] = [50, 100, 300]

func judge_hit(ring_index: int) -> void:
	if ring_index < 0:
		emit_signal("missed")
		return
	
	var score = RING_SCORES[ring_index]
	emit_signal("hit_result", ring_index, score)
