extends CharacterBody2D

const GRAVITY: float = 10.0

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	move_and_slide()
