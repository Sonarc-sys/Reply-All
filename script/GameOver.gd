extends Control

@onready var score_label  = $ScoreLabel
@onready var stats_label  = $StatsLabel

func _ready():
	var handled = GameManager.incidents_handled
	var failed  = GameManager.incidents_failed
	var danger  = GameManager.danger

	score_label.text = "Final Score:  %d" % GameManager.score
	stats_label.text = "Handled: %d     Failed: %d" % [handled, failed]

	# Optional nodes that may or may not exist in the scene
	var flavour_lbl = get_node_or_null("FlavourLabel")
	var streak_lbl  = get_node_or_null("StreakLabel")

	if flavour_lbl:
		var flavour = ""
		if danger >= 100.0:
			flavour = "The company is compromised. You had ONE job."
		elif failed == 0:
			flavour = "Perfect shift. The CEO actually noticed."
		elif failed > handled:
			flavour = "Meh. You could do better."
		else:
			flavour = "Not bad. Could've been worse."
		flavour_lbl.text = flavour

	if streak_lbl and "best_streak" in GameManager:
		streak_lbl.text = "Best Streak: %d" % GameManager.best_streak

func _on_play_again_pressed():
	# Restart music before going to intro
	if has_node("/root/AudioManager"):
		var music = load("res://audio/menu_music.wav")
		if music: get_node("/root/AudioManager").play_music(music)
	GameManager.score             = 0
	GameManager.time_left         = GameManager.shift_duration
	GameManager.day_over          = false
	GameManager.incidents_handled = 0
	GameManager.incidents_failed  = 0
	GameManager.danger            = 0.0
	GameManager.lockdown_active   = false
	GameManager.wrong_answers.clear()
	GameManager.employees.clear()
	GameManager.active_escalations.clear()
	if "current_streak" in GameManager: GameManager.current_streak = 0
	if "best_streak" in GameManager:    GameManager.best_streak    = 0
	if "unsucessful_job_hist" in GameManager:
		GameManager.unsucessful_job_hist.clear()
	get_tree().change_scene_to_file("res://scene/Intro.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scene/MainMenu.tscn")

func _on_reflection_pressed():
	get_tree().change_scene_to_file("res://scene/ReflectionReport.tscn")

func _on_reflection_report_pressed():
	get_tree().change_scene_to_file("res://scene/ReflectionReport.tscn")
