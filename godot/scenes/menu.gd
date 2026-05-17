extends Control


func _on_press_play() -> void:
	GameStateManager.go_to_map_select()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("document.cookie = 'GameToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;'")
		JavaScriptBridge.eval("window.location.href = '/'")
	else:
		get_tree().quit(0)


func _on_setting_pressed() -> void:
	GameStateManager.go_to_settings()
