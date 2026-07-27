extends Node

# AudioManager  -  plays music and SFX
# Attach as autoload: AudioManager

var music_player: AudioStreamPlayer
var sfx_players:  Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE = 6

func _ready():
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.autoplay = false
	add_child(music_player)

	# SFX pool
	for i in range(SFX_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)

func play_music(stream: AudioStream, _loop: bool = true, volume_db: float = -10.0):
	if stream == null:
		return
	# Enable looping on WAV streams
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end   = stream.get_length() * stream.mix_rate if stream.mix_rate > 0 else 0
	music_player.stream    = stream
	music_player.volume_db = volume_db
	music_player.play()
	# Connect finished signal to restart for looping
	if not music_player.finished.is_connected(_on_music_finished):
		music_player.finished.connect(_on_music_finished)

func _on_music_finished():
	if music_player.stream != null:
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0):
	if stream == null:
		return
	# Find idle player
	for p in sfx_players:
		if not p.playing:
			p.stream      = stream
			p.volume_db   = volume_db
			p.pitch_scale = pitch
			p.play()
			return
	# All busy  -  use first one
	sfx_players[0].stream    = stream
	sfx_players[0].volume_db = volume_db
	sfx_players[0].play()
