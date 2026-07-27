extends Control

@onready var score_label      = $VBox/ScoreLabel
@onready var stats_label      = $VBox/StatsLabel
@onready var flavour_label    = $VBox/FlavourLabel
@onready var streak_label     = $VBox/StreakLabel

func _ready():
	# Flavour message based on performance
	var handled = GameManager.incidents_handled
	var failed  = GameManager.incidents_failed
	var danger  = GameManager.danger

	var flavour = ""
	if danger >= 100.0:
		flavour = "The company is compromised. You had ONE job."
	elif failed == 0:
		flavour = "Perfect shift. The CEO actually noticed. Enjoy it."
	elif handled > failed * 3:
		flavour = "Not bad. Not great. But the servers are still on."
	elif failed > handled:
		flavour = "Meh. You could do better.\nMaybe try turning yourself off and on again."
	else:
		flavour = "Could've been worse. Could've been better.\nAt least nobody cried."

	score_label.text   = "Final Score:  %d" % GameManager.score
	stats_label.text   = "✅  Handled: %d     ❌  Failed: %d" % [handled, failed]
	streak_label.text  = "🔥 Best Streak: %d" % GameManager.best_streak
	flavour_label.text = flavour



func _on_reflection_pressed():
	get_tree().change_scene_to_file("res://scene/ReflectionReport.tscn")

func _on_play_again_pressed():
	GameManager.score             = 0
	GameManager.time_left         = GameManager.shift_duration
	GameManager.day_over          = false
	GameManager.incidents_handled = 0
	GameManager.incidents_failed  = 0
	GameManager.current_streak    = 0
	GameManager.best_streak       = 0
	GameManager.danger            = 0.0
	GameManager.lockdown_active   = false
	GameManager.wrong_answers.clear()
	GameManager.employees.clear()
	GameManager.active_escalations.clear()
	get_tree().change_scene_to_file("res://scene/Intro.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scene/MainMenu.tscn")
