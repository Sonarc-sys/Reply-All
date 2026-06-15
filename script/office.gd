extends Node2D


var current_employee = null


func _ready():
	for employee in $Employees.get_children():
		GameManager.register_employee(employee)
		if !employee.issue_clicked.is_connected(show_issue):
			employee.issue_clicked.connect(show_issue)

func _on_incident_timer_timeout():
	GameManager.spawn_issue()

func show_issue(employee):
	current_employee = employee
	$IssuePopup.open(employee)
	print("Opening popup")
