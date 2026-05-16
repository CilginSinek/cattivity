# res://scenes/HUD.gd
extends Control

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel

func _ready() -> void:
	var score_manager = get_node("/root/main/Gameplay/ScoreManager")
	score_manager.score_updated.connect(_on_score_updated)
	score_manager.combo_changed.connect(_on_combo_changed)
	
	score_label.text = "Score: 0"
	combo_label.text = "Combo: 0"

func _on_score_updated(score: int) -> void:
	score_label.text = "Score: %d" % score

func _on_combo_changed(combo: int) -> void:
	combo_label.text = "Combo: %d" % combo
