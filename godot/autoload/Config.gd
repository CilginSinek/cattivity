# res://autoload/Config.gd
extends Node

const BASE_URL: String = "http://localhost:5000"
const FORTYTWO_CLIENT_ID: String = "BURAYA_CLIENT_ID"
var jwt_token: String = ""

func get_auth_header() -> String:
	return "Bearer " + jwt_token
