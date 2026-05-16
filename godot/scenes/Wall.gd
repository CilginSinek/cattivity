# res://scenes/Wall.gd
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var score_manager = get_node("/root/main/Gameplay/ScoreManager")
		score_manager.add_miss()
