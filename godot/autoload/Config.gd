# res://autoload/Config.gd
extends Node

const BASE_URL: String = "http://localhost:5000"
const FORTYTWO_CLIENT_ID: String = "u-s4t2ud-b017737873b270c53cd5373ee7d0874a5c7cfb671a11dcf8b7ff0cac8c21efa0"
var jwt_token: String = ""
var current_user: Dictionary = {}  # { name, coalition, email, _id, ... }

func get_auth_header() -> String:
	return "Bearer " + jwt_token

# Game speed settings
var gravity: float = 300.0
var spawn_distance: float = 1500.0

# World scroll speed (px per ms) — tüm timing buradan yönetilir
const PIXELS_PER_MS: float = 0.3
