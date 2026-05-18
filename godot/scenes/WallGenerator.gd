# res://scenes/WallGenerator.gd
extends Node2D

const HALF_WIDTH: float = 90.0
const WALL_THICKNESS: float = 24.0
const GAP_HEIGHT: float = 130.0
const TURN_ANGLE: float = PI / 4.0 # 45 derece dönme
const WALL_COLOR: Color = Color(0.25, 0.25, 0.35, 1.0)
const END_WALL_EXTRA: float = 600.0

func calculate_path(notes: Array, duration_ms: float, start_pos: Vector2 = Vector2.ZERO) -> Array:
	var ppm: float = Config.PIXELS_PER_MS
	var path: Array = [start_pos]
	var current_pos = start_pos
	var current_dir = Vector2(0, 1) # Başlangıç yönü aşağı (dik)
	var last_time = 0.0
	
	for note in notes:
		var dist = (note.time_ms - last_time) * ppm
		current_pos += current_dir * dist
		path.append(current_pos)
		last_time = note.time_ms
		
		if note.direction == 0:
			current_dir = current_dir.rotated(TURN_ANGLE)
		else:
			current_dir = current_dir.rotated(-TURN_ANGLE)
			
	var dist_end = (duration_ms - last_time) * ppm + END_WALL_EXTRA
	current_pos += current_dir * dist_end
	path.append(current_pos)
	
	return path

var chunks: Array = []
var current_chunk_idx: int = -1

func _process(_delta: float) -> void:
	if chunks.is_empty() or not SongManager.is_playing:
		return
		
	var st = SongManager.song_time
	var notes = BeatmapController.get_notes()
	
	var idx = 0
	for i in range(notes.size()):
		if st < notes[i].time_ms:
			idx = i
			break
		idx = i + 1
		
	if idx != current_chunk_idx:
		current_chunk_idx = idx
		_update_chunks()

func _update_chunks() -> void:
	for i in range(chunks.size()):
		var chunk = chunks[i]
		# Sadece aktif oyuncunun bulunduğu segmentin 2 gerisi ve 5 ilerisini göster
		var is_active = (i >= current_chunk_idx - 2) and (i <= current_chunk_idx + 5)
		chunk.visible = is_active
		chunk.process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED

func generate(notes: Array, duration_ms: float, start_pos: Vector2 = Vector2.ZERO) -> void:
	for child in get_children():
		child.queue_free()
	chunks.clear()
	current_chunk_idx = -1

	var path = calculate_path(notes, duration_ms, start_pos)
	
	var left_path = _calculate_offset_path(path, -HALF_WIDTH)
	var right_path = _calculate_offset_path(path, HALF_WIDTH)
	
	for i in range(path.size() - 1):
		var chunk = Node2D.new()
		chunk.name = "Chunk_" + str(i)
		add_child(chunk)
		chunks.append(chunk)
		
		_build_segment(chunk, left_path, notes, 0, i)
		_build_segment(chunk, right_path, notes, 1, i)
		
	if path.size() >= 2 and chunks.size() > 0:
		_draw_end_wall(chunks.back(), path[path.size() - 1], path[path.size() - 2])
		
	_update_chunks()

func _calculate_offset_path(path: Array, offset: float) -> Array:
	var out: Array = []
	for i in range(path.size()):
		var p = path[i]
		var dir_in = Vector2.ZERO
		var dir_out = Vector2.ZERO
		
		if i > 0:
			dir_in = (p - path[i-1]).normalized()
		if i < path.size() - 1:
			dir_out = (path[i+1] - p).normalized()
			
		if i == 0:
			dir_in = dir_out
		elif i == path.size() - 1:
			dir_out = dir_in
			
		var n_in = dir_in.rotated(-PI/2)
		var n_out = dir_out.rotated(-PI/2)
		
		if dir_in.dot(dir_out) > 0.999: # Düz çizgi
			out.append(p + n_in * offset)
		else:
			var miter_dir = (n_in + n_out).normalized()
			var miter_len = offset / max(miter_dir.dot(n_in), 0.01)
			out.append(p + miter_dir * miter_len)
	return out

func _build_segment(chunk: Node2D, offset_path: Array, notes: Array, wall_side: int, i: int) -> void:
	var p1 = offset_path[i]
	var p2 = offset_path[i+1]
	var dir = (p2 - p1).normalized()
	
	var has_gap_start = i > 0 and (i - 1) < notes.size() and notes[i-1].direction == wall_side
	var has_gap_end = i < notes.size() and notes[i].direction == wall_side
	
	var start_p = p1
	var end_p = p2
	
	if has_gap_start:
		start_p = p1 + dir * (GAP_HEIGHT * 0.5)
	if has_gap_end:
		end_p = p2 - dir * (GAP_HEIGHT * 0.5)
		
	if start_p.distance_squared_to(p1) > end_p.distance_squared_to(p1):
		return # Gap has consumed the segment
		
	var pts = [start_p, end_p]
	var line = Line2D.new()
	line.default_color = WALL_COLOR
	line.width = WALL_THICKNESS
	line.begin_cap_mode = Line2D.LINE_CAP_BOX
	line.end_cap_mode = Line2D.LINE_CAP_BOX
	line.points = PackedVector2Array(pts)
	chunk.add_child(line)
	
	var body = StaticBody2D.new()
	var seg = SegmentShape2D.new()
	seg.a = start_p
	seg.b = end_p
	var col = CollisionShape2D.new()
	col.shape = seg
	body.add_child(col)
	chunk.add_child(body)

func _draw_end_wall(chunk: Node2D, end_pos: Vector2, prev_pos: Vector2) -> void:
	var w: float = HALF_WIDTH * 2.0 + WALL_THICKNESS * 2.0
	var h: float = WALL_THICKNESS * 2.0
	
	var dir = (end_pos - prev_pos).normalized()
	
	var rect = ColorRect.new()
	rect.color = Color(0.7, 0.2, 0.2, 1.0)
	rect.size = Vector2(w, h)
	rect.position = Vector2(-w * 0.5, -h * 0.5)
	
	var wrapper = Node2D.new()
	wrapper.position = end_pos
	wrapper.rotation = dir.angle() - PI/2
	wrapper.add_child(rect)
	chunk.add_child(wrapper)

	var body = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(w, h)
	col.shape = shape
	body.position = end_pos
	body.rotation = dir.angle() - PI/2
	body.add_child(col)
	chunk.add_child(body)
