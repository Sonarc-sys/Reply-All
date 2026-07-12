extends Node2D


var current_employee = null


func _ready():
	# Loop through existing employees and connect their signal
	for employee in get_tree().get_nodes_in_group("employees"):
		employee.issue_clicked.connect(_on_employee_interacted)

func _on_employee_interacted(employee):
	# This directly triggers your popup
	$IssuePopup.show_issue(employee.current_issue)

func _on_incident_timer_timeout():
	GameManager.spawn_issue()

func show_issue(employee):
	current_employee = employee
	$IssuePopup.open(employee)
	print("Opening popup")
