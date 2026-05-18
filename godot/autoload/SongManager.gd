# res://autoload/SongManager.gd
extends Node

signal song_started
signal song_ended
signal song_paused
signal song_resumed

var song_time: float = 0.0   # ms cinsinden
var is_playing: bool = false
var offset_ms: float = 0.0
var duration_ms: float = 0.0

# Web: HTML Audio üzerinden JS callback
var _js_audio_ref = null
var _js_ended_callback = null

# Desktop fallback
@onready var _player: AudioStreamPlayer = AudioStreamPlayer.new()
var _http: HTTPRequest

func _ready() -> void:
	add_child(_player)
	_player.finished.connect(_on_song_finished)

	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_desktop_download_complete)

func _process(_delta: float) -> void:
	if not is_playing:
		return

	if OS.has_feature("web"):
		# Web: currentTime'ı JS'ten al
		var t = JavaScriptBridge.eval("window._gameAudio ? window._gameAudio.currentTime * 1000.0 : -1.0")
		if typeof(t) == TYPE_FLOAT or typeof(t) == TYPE_INT:
			song_time = float(t)
			# Manuel bitiş kontrolü (JS ended event yerine yedek)
			if duration_ms > 0 and song_time >= duration_ms:
				_on_song_finished()
	else:
		song_time = _player.get_playback_position() * 1000.0

func load_and_play_url(audio_url: String) -> void:
	var full_url = Config.BASE_URL + audio_url

	if OS.has_feature("web"):
		var offset_s: float = offset_ms / 1000.0
		var js_code = """
			(function() {
				if (window._gameAudio) { window._gameAudio.pause(); window._gameAudio = null; }
				window._gameAudio = new Audio('%s');
				window._gameAudio.addEventListener('canplay', function() {
					window._gameAudio.currentTime = %f;
					window._gameAudio.play().catch(function(e){ console.error('Audio play failed:', e); });
				}, { once: true });
				window._gameAudio.load();
			})();
		""" % [full_url, offset_s]
		JavaScriptBridge.eval(js_code)
		is_playing = true
		song_time = offset_ms
		emit_signal("song_started")
	else:
		_http.request(full_url, ["Authorization: " + Config.get_auth_header()])

func _on_desktop_download_complete(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("SongManager: audio download başarısız: " + str(response_code))
		return
	var stream = AudioStreamMP3.new()
	stream.data = body
	_player.stream = stream
	_player.play(offset_ms / 1000.0)  # offset noktasından başlat
	is_playing = true
	song_time = offset_ms
	emit_signal("song_started")

func play() -> void:
	if not OS.has_feature("web") and _player.stream != null:
		_player.play()
	is_playing = true
	song_time = 0.0
	emit_signal("song_started")

func pause() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if(window._gameAudio) window._gameAudio.pause();")
	else:
		_player.stream_paused = true
	is_playing = false
	emit_signal("song_paused")

func resume() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if(window._gameAudio) window._gameAudio.play();")
	else:
		_player.stream_paused = false
	is_playing = true
	emit_signal("song_resumed")

func stop() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if(window._gameAudio){ window._gameAudio.pause(); window._gameAudio.currentTime=0; }")
	else:
		_player.stop()
	is_playing = false
	song_time = 0.0

func set_offset(ms: float) -> void:
	offset_ms = ms

func set_duration(ms: float) -> void:
	duration_ms = ms

func _on_song_finished() -> void:
	if not is_playing:
		return
	is_playing = false
	emit_signal("song_ended")
	GameStateManager.end_game()
