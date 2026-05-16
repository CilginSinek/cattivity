# res://scenes/notes/CircleNote.gd
extends Node2D

signal hit(ring_index: int)
signal missed

const RING_RADII: Array[float] = [120.0, 80.0, 40.0]
const RING_COLORS: Array[Color] = [
	Color(1, 1, 1, 0.3),
	Color(1, 1, 1, 0.6),
	Color(1, 1, 1, 1.0),
]

var time_ms: float = 0.0
var direction: int = 0  # 0 = sol, 1 = sağ
var is_hit: bool = false

@onready var hit_area: Area2D = $HitArea
@onready var rings: Node2D = $Rings

func _ready() -> void:
	_draw_rings()

func _draw_rings() -> void:
	for i in range(RING_RADII.size()):
		var line = Line2D.new()
		line.width = 3.0
		line.default_color = RING_COLORS[i]
		var points: PackedVector2Array = []
		for j in range(361):
			var angle = deg_to_rad(float(j))
			points.append(Vector2(
				cos(angle) * RING_RADII[i],
				sin(angle) * RING_RADII[i]
			))
		line.points = points
		rings.add_child(line)

func check_hit(touch_position: Vector2) -> int:
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
