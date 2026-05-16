# res://scenes/Login.gd
extends Control

@onready var login_button: Button = $LoginButton

func _ready() -> void:
	login_button.pressed.connect(_on_login_pressed)
	_check_token()


func _check_token() -> void:
	if OS.has_feature("web"):
		# URL'den token al: /?token=xxx
		var token = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('token') || ''")
		if token != "":
			Config.jwt_token = token
			GameStateManager.go_to_menu()
		else:
			# Cookie'den de kontrol et
			var cookie_token = JavaScriptBridge.eval("document.cookie.match(/GameToken=([^;]+)/)?.[1] || ''")
			if cookie_token != "":
				Config.jwt_token = cookie_token
				GameStateManager.go_to_menu()
	else:
		GameStateManager.go_to_menu()

func _on_login_pressed() -> void:
	var client_id = Config.FORTYTWO_CLIENT_ID
	var redirect_uri = (Config.BASE_URL + "/auth/42/callback").uri_encode()
	var url = "https://api.intra.42.fr/oauth/authorize?client_id=" + client_id + "&redirect_uri=" + redirect_uri + "&response_type=code&scope=public"
	JavaScriptBridge.eval("window.open('" + url + "', '_self')")
