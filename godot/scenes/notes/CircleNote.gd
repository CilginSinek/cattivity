# res://scenes/notes/CircleNote.gd
# İç içe 2 ring: inner = perfect zone, outer = good zone.
# Direction'a göre renk ve ok işareti gösterir.
extends Node2D

var time_ms: float = 0.0
var direction: int = 0   # 0 = sol (A tuşu), 1 = sağ (D tuşu)
var is_hit: bool = false

# Ring yarıçapları [outer, inner]
const OUTER_RADIUS: float = 100.0
const INNER_RADIUS: float = 60.0
const RING_WIDTH: float = 4.0
const SHRINK_SPEED: float = 0.6  # outer ring küçülme oranı (1.0 = sabit)

# Direction renkleri
const COLOR_LEFT: Color = Color(0.3, 0.6, 1.0, 0.9)    # mavi = sol
const COLOR_RIGHT: Color = Color(1.0, 0.5, 0.15, 0.9)  # turuncu = sağ
const COLOR_INNER: Color = Color(1.0, 1.0, 1.0, 1.0)   # beyaz iç ring

var _outer_ring: Node2D
var _inner_ring: Node2D
var _arrow_label: Label
var _ring_color: Color

func _ready() -> void:
	_ring_color = COLOR_LEFT if direction == 0 else COLOR_RIGHT
	_build_rings()
	_build_arrow()

func _build_rings() -> void:
	# Outer ring (good zone)
	_outer_ring = Node2D.new()
	add_child(_outer_ring)
	_draw_circle_ring(_outer_ring, OUTER_RADIUS, _ring_color, RING_WIDTH)

	# Inner ring (perfect zone)
	_inner_ring = Node2D.new()
	add_child(_inner_ring)
	_draw_circle_ring(_inner_ring, INNER_RADIUS, COLOR_INNER, RING_WIDTH + 1.0)

func _draw_circle_ring(parent: Node2D, radius: float, color: Color, width: float) -> void:
	var line = Line2D.new()
	line.default_color = color
	line.width = width
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	var pts: PackedVector2Array = []
	var segments: int = 48
	for i in range(segments + 1):
		var angle: float = (float(i) / float(segments)) * TAU
		pts.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	line.points = pts
	parent.add_child(line)

func _build_arrow() -> void:
	# Yön göstergesi: ◀ veya ▶
	_arrow_label = Label.new()
	_arrow_label.text = "◀" if direction == 0 else "▶"
	_arrow_label.add_theme_font_size_override("font_size", 20)
	_arrow_label.add_theme_color_override("font_color", _ring_color)
	_arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_arrow_label.position = Vector2(-15, -14)
	add_child(_arrow_label)

func _process(_delta: float) -> void:
	if is_hit:
		return
	# Outer ring hafifçe büyüyüp küçülsün (nefes efekti)
	var t: float = Time.get_ticks_msec() * 0.001
	var pulse: float = 1.0 + sin(t * 4.0) * 0.05
	if _outer_ring:
		_outer_ring.scale = Vector2(pulse, pulse)

func mark_hit() -> void:
	is_hit = true
	# Kısa parlaklık efekti sonra sil
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
