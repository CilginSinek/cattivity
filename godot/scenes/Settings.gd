# res://scenes/Settings.gd
extends Control

@onready var volume_slider: HSlider = $CenterContainer/VBoxContainer/VolumeRow/VolumeSlider
@onready var key_left_button: Button = $CenterContainer/VBoxContainer/KeyLeftRow/KeyLeftButton
@onready var key_right_button: Button = $CenterContainer/VBoxContainer/KeyRightRow/KeyRightButton
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

var listening_for_key: String = ""

func _ready() -> void:
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.value = AudioServer.get_bus_volume_db(0)
	
	volume_slider.value_changed.connect(_on_volume_changed)
	key_left_button.pressed.connect(_on_key_left_pressed)
	key_right_button.pressed.connect(_on_key_right_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	_update_key_labels()

func _input(event: InputEvent) -> void:
	if listening_for_key == "":
		return
	if event is InputEventKey and event.pressed:
		var action = "rotate_left" if listening_for_key == "left" else "rotate_right"
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		listening_for_key = ""
		_update_key_labels()

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_key_left_pressed() -> void:
	listening_for_key = "left"
	key_left_button.text = "Bas..."

func _on_key_right_pressed() -> void:
	listening_for_key = "right"
	key_right_button.text = "Bas..."

func _update_key_labels() -> void:
	var left_events = InputMap.action_get_events("rotate_left")
	if left_events.size() > 0:
		key_left_button.text = OS.get_keycode_string(left_events[0].keycode)
	
	var right_events = InputMap.action_get_events("rotate_right")
	if right_events.size() > 0:
		key_right_button.text = OS.get_keycode_string(right_events[0].keycode)

func _on_back_pressed() -> void:
	GameStateManager.go_to_menu()
