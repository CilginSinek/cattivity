# res://scenes/Gameplay.gd
extends Node2D$CenterContainer/Button

const ROTATION_STEP: float = 15.0
const MAX_ROTATION: float = 90.0
const ROTATION_SPEED: float = 8.0

var target_rotation: float = 0.0
var current_rotation: float = 0.0

@onready var notes_container: Node = $Notes
@onready var effects_container: Node = $Effects
@onready var player: CharacterBody2D = get_node("/root/main/Player")
@onready var judge_system: Node = $JudgeSystem
@onready var score_manager: Node = $ScoreManager"res://scenes/Main.tscn"

func _ready() -> void:
	judge_system.hit_result.connect(_on_hit_result)
	judge_system.missed.connect(score_manager.add_miss)

func _process(delta: float) -> void:
	_handle_input()
	_apply_rotation(delta)
	_follow_player()

func _handle_input() -> void:
	if Input.is_action_just_pressed("rotate_left"):
		target_rotation -= ROTATION_STEP
		target_rotation = clamp(target_rotation, -MAX_ROTATION, MAX_ROTATION)
	
	if Input.is_action_just_pressed("rotate_right"):
		target_rotation += ROTATION_STEP
		target_rotation = clamp(target_rotation, -MAX_ROTATION, MAX_ROTATION)

func _apply_rotation(delta: float) -> void:
	current_rotation = lerp(current_rotation, target_rotation, ROTATION_SPEED * delta)
	rotation_degrees = current_rotation

func _follow_player() -> void:
	if player:
		global_position = player.global_position

func _on_hit_result(ring_index: int, score: int) -> void:
	score_manager.add_hit(score)

func reset() -> void:
	target_rotation = 0.0
	current_rotation = 0.0
	rotation_degrees = 0.0
