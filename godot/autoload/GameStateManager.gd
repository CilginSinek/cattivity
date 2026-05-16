# res://autoload/GameStateManager.gd
extends Node

signal state_changed(new_state: String)

enum State { MENU, PLAYING, PAUSED, RESULT }

var current_state: State = State.MENU

func go_to_menu() -> void:
	_set_state(State.MENU)

func start_game() -> void:
	_set_state(State.PLAYING)

func pause_game() -> void:
	if current_state == State.PLAYING:
		_set_state(State.PAUSED)

func resume_game() -> void:
	if current_state == State.PAUSED:
		_set_state(State.PLAYING)

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
