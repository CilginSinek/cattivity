extends Control


func _on_press_play() -> void:
	GameStateManager.start_game()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)


func _on_setting_pressed() -> void:
	GameStateManager.go_to_settings()
