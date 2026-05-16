# res://scenes/Player.gd
extends CharacterBody2D

const GRAVITY: float = 980.0
const MOVE_SPEED: float = 300.0

func _physics_process(delta: float) -> void:
	# Gravity her zaman aşağı (dünya koordinatında)
	velocity.y += GRAVITY * delta
	
	move_and_slide()
