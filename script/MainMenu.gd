extends Control

func _ready():
	AudioManager.play_music(load("res://audio/menu_music.wav"))
	GameManager.score = 0
	GameManager.time_left = 180.0
	GameManager.day_over  = false
	GameManager.incidents_handled = 0
	GameManager.incidents_failed  = 0
	GameManager.current_streak    = 0
	GameManager.best_streak       = 0
	GameManager.wrong_answers.clear()
	GameManager.employees.clear()
	GameManager.active_escalations.clear()
	GameManager.danger = 0.0
	GameManager.lockdown_active = false

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scene/Intro.tscn")

func _on_exit_pressed():
	get_tree().quit()

func _on_options_pressed():
	get_tree().change_scene_to_file("res://scene/Options.tscn")
