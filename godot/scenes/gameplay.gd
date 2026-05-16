# res://scenes/Gameplay.gd
extends Node2D

const ROTATION_STEP: float = 15.0
const MAX_ROTATION: float = 90.0
const ROTATION_SPEED: float = 24.0

var target_rotation: float = 0.0
var current_rotation: float = 0.0

@onready var notes_container: Node = $Notes
@onready var effects_container: Node = $Effects
@onready var player: CharacterBody2D = get_node("/root/main/Player")

func _ready() -> void:
	pass

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
#		Basılı tutma istenirse bunu aç
#func _handle_input() -> void:
	#if Input.is_action_pressed("rotate_left"):
		#target_rotation -= ROTATION_STEP * get_process_delta_time()
		#target_rotation = clamp(target_rotation, -MAX_ROTATION, MAX_ROTATION)
	#
	#if Input.is_action_pressed("rotate_right"):
		#target_rotation += ROTATION_STEP * get_process_delta_time()
		#target_rotation = clamp(target_rotation, -MAX_ROTATION, MAX_ROTATION)

func _apply_rotation(delta: float) -> void:
	current_rotation = lerp(current_rotation, target_rotation, ROTATION_SPEED * delta)
	rotation_degrees = current_rotation

func _follow_player() -> void:
	if player:
		# Gameplay'in pozisyonu oyuncuya kilitli
		# Rotation merkezi de böylece oyuncu oluyor
		global_position = player.global_position

func reset() -> void:
	target_rotation = 0.0
	current_rotation = 0.0
	rotation_degrees = 0.0
