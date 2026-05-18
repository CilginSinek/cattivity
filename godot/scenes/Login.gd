# res://scenes/Login.gd
extends Control

@onready var login_button: Button = $CenterContainer/VBoxContainer/LoginButton

var _http: HTTPRequest

func _ready() -> void:
	login_button.pressed.connect(_on_login_pressed)
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_user_info_received)
	_check_token()

func _check_token() -> void:
	if OS.has_feature("web"):
		# Önce URL parametresinde token ara
		var token = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('token') || ''")
		if token != "":
			Config.jwt_token = token
			_fetch_user_info()
			return

		# Cookie'de ara
		var cookie_token = JavaScriptBridge.eval("document.cookie.match(/GameToken=([^;]+)/)?.[1] || ''")
		if cookie_token != "":
			Config.jwt_token = cookie_token
			_fetch_user_info()
			return

		# Token yok, login ekranı göster
		login_button.visible = true
	else:
		# Desktop geliştirme: auth atla, direkt menüye git
		GameStateManager.go_to_menu()

func _fetch_user_info() -> void:
	login_button.visible = false
	var headers = ["Authorization: " + Config.get_auth_header()]
	var err = _http.request(Config.BASE_URL + "/", headers)
	if err != OK:
		push_error("Login: user info request failed: " + str(err))

func _on_user_info_received(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("Login: user info fetch failed: " + str(response_code))
		# Token geçersiz olabilir — login ekranını göster
		login_button.visible = true
		return

	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		push_error("Login: JSON parse failed")
		login_button.visible = true
		return

	var data = json.data
	Config.current_user = data.get("user", {})
	GameStateManager.go_to_menu()

func _on_login_pressed() -> void:
	var client_id = Config.FORTYTWO_CLIENT_ID
	var redirect_uri = (Config.BASE_URL + "/auth/42/callback").uri_encode()
	var url = "https://api.intra.42.fr/oauth/authorize?client_id=" + client_id + "&redirect_uri=" + redirect_uri + "&response_type=code&scope=public"
	JavaScriptBridge.eval("window.open('" + url + "', '_self')")
