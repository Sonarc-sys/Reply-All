extends Control

@onready var score_label = $ScoreLabel
@onready var stats_label = $StatsLabel

func _ready():
	score_label.text = "Score: %d" % GameManager.score
	stats_label.text = "Handled: %d     Failed: %d" % [
		GameManager.incidents_handled,
		GameManager.incidents_failed
	]

func _on_play_again_pressed():
	GameManager.score = 0
	GameManager.time_left = 60
	GameManager.day_over = false
	GameManager.incidents_handled = 0
	GameManager.incidents_failed = 0
	GameManager.employees.clear()
	get_tree().change_scene_to_file("res://scene/office.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scene/MainMenu.tscn")


func _on_reflection_report_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/scoreboard.tscn")
