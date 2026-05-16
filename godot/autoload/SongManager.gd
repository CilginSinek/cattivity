# res://autoload/SongManager.gd
extends Node

signal song_started
signal song_ended
signal song_paused
signal song_resumed

var song_time: float = 0.0
var is_playing: bool = false
var offset_ms: float = 0.0

@onready var _player: AudioStreamPlayer = AudioStreamPlayer.new()
var _http: HTTPRequest

func _ready() -> void:
	add_child(_player)
	_player.finished.connect(_on_song_finished)
	
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_download_complete)

func _process(delta: float) -> void:
	if is_playing:
		song_time += delta * 1000.0

func load_and_play(package_url: String) -> void:
	var full_url = Config.BASE_URL + package_url
	_http.request(full_url)

func _on_download_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("SongManager: download failed")
		return
	
	var temp_path = "user://temp_package.zip"
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	
	var zip = ZIPReader.new()
	var err = zip.open(temp_path)
	if err != OK:
		push_error("SongManager: zip open failed")
		return
	
	var mp3_data = zip.read_file("song.mp3")
	zip.close()
	
	var stream = AudioStreamMP3.new()
	stream.data = mp3_data
	_player.stream = stream
	
	play()

func play() -> void:
	_player.play()
	is_playing = true
	song_time = 0.0
	emit_signal("song_started")

func pause() -> void:
	_player.stream_paused = true
	is_playing = false
	emit_signal("song_paused")

func resume() -> void:
	_player.stream_paused = false
	is_playing = true
	emit_signal("song_resumed")

func stop() -> void:
	_player.stop()
	is_playing = false
	song_time = 0.0

func set_offset(ms: float) -> void:
	offset_ms = ms

func _on_song_finished() -> void:
	is_playing = false
	emit_signal("song_ended")
