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
	# Find LockdownEvent robustly - try multiple paths
	var lockdown = get_node_or_null("CanvasLayer/LockdownEvent")
	if lockdown == null:
		lockdown = get_node_or_null("LockdownEvent")
	if lockdown == null:
		# Search entire scene tree
		lockdown = find_child("LockdownEvent", true, false)
	if lockdown == null:
		push_error("LockdownEvent node not found - skipping lockdown")
		GameManager.lockdown_active = false
		return
	if not lockdown.lockdown_cleared.is_connected(_on_lockdown_cleared):
		lockdown.lockdown_cleared.connect(_on_lockdown_cleared, CONNECT_ONE_SHOT)
	if not lockdown.lockdown_failed.is_connected(_on_lockdown_failed):
		lockdown.lockdown_failed.connect(_on_lockdown_failed, CONNECT_ONE_SHOT)
	lockdown.start(GameManager.employees)

func _on_lockdown_cleared():
	GameManager.lockdown_resolved()

func _on_lockdown_failed():
	GameManager.end_day()
