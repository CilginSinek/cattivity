# res://autoload/Config.gd
extends Node

const BASE_URL: String = "http://10.19.19.6:5000"
const FORTYTWO_CLIENT_ID: String = "u-s4t2ud-c94ca0bb6b25a81807c7860f603a782f0da5c9dc6487f2847bd149bf717d13a0"
var jwt_token: String = ""

func get_auth_header() -> String:
	return "Bearer " + jwt_token
# Oyun hız ayarları
var gravity: float = 300.0
var spawn_distance: float = 1500.0
