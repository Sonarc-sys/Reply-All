extends Node2D


var current_employee = null


func _ready():
	# Support both $Map/Employees and $Employees node paths
	var emp_node = get_node_or_null("Map/Employees")
	if emp_node == null:
		emp_node = get_node_or_null("Employees")
	if emp_node != null:
		for employee in emp_node.get_children():
			GameManager.register_employee(employee)
			if !employee.issue_clicked.is_connected(show_issue):
				employee.issue_clicked.connect(show_issue)
	if not GameManager.lockdown_triggered.is_connected(_on_lockdown_triggered):
		GameManager.lockdown_triggered.connect(_on_lockdown_triggered)

func _on_incident_timer_timeout():
	GameManager.spawn_issue()

func show_issue(employee):
	if GameManager.lockdown_active:
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
