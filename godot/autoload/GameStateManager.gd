# res://autoload/GameStateManager.gd
extends Node

signal state_changed(new_state: String)

enum State { MENU, PLAYING, PAUSED, RESULT }

var current_state: State = State.MENU

func go_to_map_select() -> void:
	_set_state(State.MENU)
	get_tree().change_scene_to_file("res://scenes/MapSelect.tscn")

func go_to_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func go_to_leaderboard() -> void:
	get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")

func go_to_menu() -> void:
	_set_state(State.MENU)
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func start_game() -> void:
	_set_state(State.PLAYING)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func pause_game() -> void:
	if current_state == State.PLAYING:
		_set_state(State.PAUSED)
		get_tree().paused = true

func resume_game() -> void:
	if current_state == State.PAUSED:
		_set_state(State.PLAYING)
		get_tree().paused = false

func end_game() -> void:
	_set_state(State.RESULT)

func _set_state(new_state: State) -> void:
	current_state = new_state
	var name_map = {
		State.MENU: "MENU",
		State.PLAYING: "PLAYING",
		State.PAUSED: "PAUSED",
		State.RESULT: "RESULT"
	}
	emit_signal("state_changed", name_map[new_state])
