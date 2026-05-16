# res://scenes/notes/CircleNote.gd
extends Node2D

signal hit(ring_index: int)
signal missed

# Kaç iç içe çember var (dıştan içe: 0, 1, 2)
# 0 = en dış (50 puan), 1 = orta (100 puan), 2 = en iç (300 puan)
const RING_RADII: Array[float] = [120.0, 80.0, 40.0]
const RING_COLORS: Array[Color] = [
	Color(1, 1, 1, 0.3),   # dış
	Color(1, 1, 1, 0.6),   # orta
	Color(1, 1, 1, 1.0),   # iç
]

var time_ms: float = 0.0  # BeatmapController'dan gelecek
var is_hit: bool = false

@onready var hit_area: Area2D = $HitArea
@onready var rings: Node2D = $Rings

func _ready() -> void:
	_draw_rings()
	hit_area.input_event.connect(_on_input_event)

func _draw_rings() -> void:
	for i in range(RING_RADII.size()):
		var circle = ColorRect.new()
		# Şimdilik placeholder, sonra gerçek çember çizeceğiz
		rings.add_child(circle)

func check_hit(touch_position: Vector2) -> int:
	# Dokunulan noktanın hangi çemberde olduğunu döndür
	# -1 = miss, 0 = dış, 1 = orta, 2 = iç
	var dist = global_position.distance_to(touch_position)
	for i in range(RING_RADII.size() - 1, -1, -1):
		if dist <= RING_RADII[i]:
			return i
	return -1

func on_player_hit(touch_position: Vector2) -> void:
	if is_hit:
		return
	var ring = check_hit(touch_position)
	if ring >= 0:
		is_hit = true
		emit_signal("hit", ring)
		queue_free()
	else:
		emit_signal("missed")
