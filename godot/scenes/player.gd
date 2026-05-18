extends CharacterBody2D

# Player ekranın alt-ortasında sabit durur.
# Hareket yok — WorldContainer kayarak düşme illüzyonu yaratır.
# Kapatma duvarıyla çarpışma: StaticBody2D → move_and_slide ile tespit
func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	var collided = move_and_slide()
	if collided and SongManager.is_playing:
		# Herhangi bir duvara çarptı → oyun biter
		SongManager.stop()
		GameStateManager.end_game()
