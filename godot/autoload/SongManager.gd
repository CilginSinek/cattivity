# res://autoload/SongManager.gd
extends Node

signal song_started
signal song_ended
signal song_paused
signal song_resumed

var song_time: float = 0.0
var is_playing: bool = false
var offset_ms: float = 0.0  # kullanıcı ayarlarından gelecek

@onready var _player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(_player)
	_player.finished.connect(_on_song_finished)

func _process(_delta: float) -> void:
	if is_playing:
		song_time = (_player.get_playback_position() * 1000.0) + offset_ms

func load_song(stream: AudioStream) -> void:
	_player.stream = stream

func play() -> void:
	_player.play()
	is_playing = true
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
