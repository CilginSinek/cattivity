extends CharacterBody2D

const GRAVITY: float = 300.0

func _physics_process(delta: float) -> void:
	velocity.y += Config.gravity * delta
	move_and_slide()
