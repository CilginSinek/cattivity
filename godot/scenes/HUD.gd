# res://scenes/HUD.gd
extends Control

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var health_label: Label = $HealthLabel

func _ready() -> void:
	# ScoreManager yolu Main.tscn yapısına göre güncellendi
	var score_manager = get_node_or_null("/root/main/GameplayInput/ScoreManager")
	if score_manager:
		score_manager.score_updated.connect(_on_score_updated)
		score_manager.combo_changed.connect(_on_combo_changed)

	score_label.text = "Skor: 0"
	combo_label.text = "Kombo: 0"
	health_label.text = "♥  1 Hak"

func _on_score_updated(score: int) -> void:
	score_label.text = "Skor: %d" % score

func _on_combo_changed(combo: int) -> void:
	combo_label.text = "Kombo: %d" % combo
