extends Node2D


var current_employee = null


func _ready():
	GameManager.time_left = GameManager.shift_duration
	if not GameManager.day_ended.is_connected(_on_day_ended):
		GameManager.day_ended.connect(_on_day_ended)
	if not GameManager.lockdown_triggered.is_connected(_on_lockdown_triggered):
		GameManager.lockdown_triggered.connect(_on_lockdown_triggered)
	for employee in $Employees.get_children():
		if !employee.issue_clicked.is_connected(show_issue):
			employee.issue_clicked.connect(show_issue)

func _on_incident_timer_timeout():
	GameManager.spawn_issue()

func show_issue(employee):
	if GameManager.lockdown_active:
		# During lockdown, E clears stations  -  no popup
		employee.lockdown_clear()
		return
	if not employee.has_issue:
		return
	current_employee = employee
	$CanvasLayer/IssuePopup.open(employee)

func _on_lockdown_triggered():
	var lockdown = $CanvasLayer/LockdownEvent
	lockdown.lockdown_cleared.connect(_on_lockdown_cleared, CONNECT_ONE_SHOT)
	lockdown.lockdown_failed.connect(_on_lockdown_failed, CONNECT_ONE_SHOT)
	lockdown.start(GameManager.employees)

func _on_lockdown_cleared():
	GameManager.lockdown_resolved()

func _on_lockdown_failed():
	GameManager.end_day()

func _on_day_ended(_data):
	# Fade to black before cutscene
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().current_scene.add_child(fade)
	var tw = fade.create_tween()
	tw.tween_property(fade, "color:a", 1.0, 1.2)
	tw.tween_callback(func(): get_tree().change_scene_to_file("res://scene/GameOverTransition.tscn"))
