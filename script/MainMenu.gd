extends Control

func _ready():
	# Reset GameManager state for a fresh run
	GameManager.score = 0
	GameManager.time_left = 60
	GameManager.day_over = false
	GameManager.incidents_handled = 0
	GameManager.incidents_failed = 0
	GameManager.employees.clear()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scene/office.tscn")

func _on_exit_pressed():
	get_tree().quit()
