# res://scenes/Login.gd
extends Control

@onready var login_button: Button = $LoginButton

var _http: HTTPRequest
var _polling: bool = false

func _ready() -> void:
	login_button.pressed.connect(_on_login_pressed)
	
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_poll_complete)
	
	# Zaten login misin kontrol et
	_poll()

func _on_login_pressed() -> void:
	OS.shell_open(Config.BASE_URL + "/auth/42")
	_polling = true
	_start_polling()

func _start_polling() -> void:
	while _polling:
		await get_tree().create_timer(2.0).timeout
		_poll()

func _poll() -> void:
	_http.request(Config.BASE_URL + "/")

func _on_poll_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		_polling = false
		GameStateManager.go_to_menu()
