extends Control

@onready var music_slider  = $Panel/VBox/MusicRow/MusicSlider
@onready var sfx_slider    = $Panel/VBox/SFXRow/SFXSlider
@onready var timer_option  = $Panel/VBox/TimerRow/TimerOption

# Stored volume values (0-100 range for sliders)
var music_vol: float = 60.0
var sfx_vol:   float = 80.0

func _ready():
	# Use stored values  -  don't rely on named audio buses which may not exist
	music_slider.value = music_vol
	sfx_slider.value   = sfx_vol
	timer_option.add_item("1 Minute",  60)
	timer_option.add_item("2 Minutes", 120)
	timer_option.add_item("3 Minutes", 180)
	match int(GameManager.shift_duration):
		60:  timer_option.select(0)
		120: timer_option.select(1)
		_:   timer_option.select(2)

func _on_music_slider_changed(value):
	music_vol = value
	# Scale 0-100 to dB (-40 to 0), use Master bus (index 0) which always exists
	var db = -40.0 + (value / 100.0) * 40.0
	AudioServer.set_bus_volume_db(0, db)
	# Also set AudioManager player directly if available
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").music_player.volume_db = db

func _on_sfx_slider_changed(value):
	sfx_vol = value
	# SFX volume stored for use when playing
	if has_node("/root/AudioManager"):
		for p in get_node("/root/AudioManager").sfx_players:
			p.volume_db = -40.0 + (value / 100.0) * 40.0

func _on_timer_option_item_selected(index):
	var durations = [60.0, 120.0, 180.0]
	GameManager.shift_duration = durations[index]

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scene/MainMenu.tscn")
