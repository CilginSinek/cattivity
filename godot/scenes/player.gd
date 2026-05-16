# res://scenes/Player.gd
extends CharacterBody2D

const GRAVITY: float = 980.0

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	move_and_slide()
	#print("player: ", global_position, " rotation: ", rotation_degrees)
