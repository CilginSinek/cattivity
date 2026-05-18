# res://scenes/Main.gd
extends Node

@onready var world_container: Node2D = $WorldContainer
@onready var wall_generator: Node2D = $WorldContainer/WallGenerator
@onready var note_spawner: Node = $WorldContainer/NoteSpawner
@onready var player: CharacterBody2D = $Player
@onready var hud: Control = $UI/HUD
@onready var result_ui: Control = $UI/ResultUI
@onready var loading_label: Label = $UI/LoadingLabel

func _ready() -> void:
	result_ui.visible = false
	hud.visible = false
	loading_label.text = "Harita yükleniyor..."
	loading_label.visible = true
	_apply_player_texture()
	BeatmapController.load_from_web(_on_map_loaded)

var user_turns: Array = []

func _on_map_loaded() -> void:
	var notes = BeatmapController.get_notes()
	var duration_ms = float(BeatmapController.map_info.get("duration", 0))

	# Player'ın WorldContainer local koordinatını başlangıç olarak al
	var player_local_x: float = player.global_position.x
	var start_pos = Vector2(player_local_x, 0.0)
	
	user_turns = [{"time_ms": 0.0, "pos": start_pos, "angle": 0.0}]

	wall_generator.generate(notes, duration_ms, start_pos)
	note_spawner.setup(notes, start_pos)

	loading_label.visible = false
	hud.visible = true

	var audio_url = BeatmapController.selected_map.get("audioUrl", "")
	SongManager.load_and_play_url(audio_url)

func _process(_delta: float) -> void:
	if not SongManager.is_playing:
		return
	
	var st = SongManager.song_time
	var ppm = Config.PIXELS_PER_MS
	
	# Sadece oyuncunun kendi döndüğü (A/D tuşları) açıya göre hareket et!
	var last_turn = user_turns.back()
	var dist = (st - last_turn.time_ms) * ppm
	var p_pos = last_turn.pos + Vector2(0, 1).rotated(last_turn.angle) * dist
	var target_angle = last_turn.angle
	
	# Smooth camera rotation
	var current_rot = world_container.rotation
	world_container.rotation = lerp_angle(current_rot, -target_angle, _delta * 15.0)
	
	# Pin the calculated path position EXACTLY to the player's screen position
	world_container.global_position = player.global_position - p_pos.rotated(world_container.rotation)

func turn_player(direction: int) -> void:
	var st = SongManager.song_time
	var ppm = Config.PIXELS_PER_MS
	var last_turn = user_turns.back()
	var dist = (st - last_turn.time_ms) * ppm
	var current_pos = last_turn.pos + Vector2(0, 1).rotated(last_turn.angle) * dist
	
	var new_angle = last_turn.angle
	var spr: Sprite2D = player.get_node_or_null("Sprite2D")
	
	if direction == 0:
		new_angle += PI / 4.0 # Sola dön
		if spr: spr.frame = 1 # Mavi dönüş animasyonu
	else:
		new_angle -= PI / 4.0 # Sağa dön
		if spr: spr.frame = 2 # Kırmızı dönüş animasyonu
		
	if spr:
		# Animasyonu kısa süre sonra tekrar idle (0) durumuna getir
		get_tree().create_timer(0.2).timeout.connect(func():
			if spr.frame == (1 if direction == 0 else 2):
				spr.frame = 0
		)
		
	user_turns.append({"time_ms": st, "pos": current_pos, "angle": new_angle})

func _apply_player_texture() -> void:
	var coalition = Config.current_user.get("coalition", "none").to_lower()
	var sprite: Sprite2D = player.get_node_or_null("Sprite2D")
	if sprite == null:
		return
	var tex_path: String = "res://assets/SPRITE_RAVENCLAW.png"
	match coalition:
		"the order", "gryffindor", "griffindor", "ignatus":      tex_path = "res://assets/SPRITE_GRYFFINDOR.png"
		"the alliance", "hufflepuff", "aerys":   tex_path = "res://assets/SPRITE_HUFFLEPUFF.png"
		"the federation", "ravenclaw", "aqualis": tex_path = "res://assets/SPRITE_RAVENCLAW.png"
		"the assembly", "slytherin", "terranos":   tex_path = "res://assets/SPRITE_SLYTHERIN.png"
		
	if ResourceLoader.exists(tex_path):
		var tex = load(tex_path)
		sprite.texture = tex
		sprite.hframes = 3
		sprite.vframes = 1
		sprite.frame = 0
		
		# Görsel çok büyük olduğu için scale uyguluyoruz
		# Her frame'in yüksekliğini yaklaşık 50-60 piksel yapalım
		if tex:
			var frame_height = float(tex.get_height())
			if frame_height > 0:
				var target_height = 64.0
				var s = target_height / frame_height
				sprite.scale = Vector2(s, s)
