extends CharacterBody2D


signal issue_clicked(employee)

@onready var name_label = $UI/NameLabel
@export var employee_name = "Employee"
@export_enum(
	"Normal",
	"Intern",
	"Manager",
	"CEO"
)
var employee_type = "Normal"

var has_issue = false
@onready var patience_bar = $UI/PatienceBar
var patience = 100
var current_issue:CyberIssue

var escalated = false


func _ready():
	name_label.text = employee_name
	GameManager.register_employee(self)
	

	#Employee personalities
	match employee_type:
		"CEO":
			patience = 70
		"Intern":
			patience = 120
		"Manager":
			patience = 90
		_:
			patience = 100




func _process(delta):
	if has_issue and !escalated:
		var urgency = current_issue.urgency
		patience -= urgency * 10 * delta
		patience_bar.value = clamp(patience,0,100)
		if patience <= 0:
			escalate()




func create_issue(issue:CyberIssue):
	has_issue = true
	escalated = false
	current_issue = issue
	# reset based on employee type
	match employee_type:
		"CEO":
			patience = 70
		"Intern":
			patience = 120
		"Manager":
			patience = 90
		_:
			patience = 100

	$UI/Exclamation.visible = true
	GameManager.incidents_changed.emit()

	print(
		employee_name,
		" received issue: ",
		issue.issue_name
	)

func interact():
	if has_issue:
		issue_clicked.emit(self)

func solve():
	var solved_issue = current_issue
	if solved_issue == null:
		print("No issue to solve")
		return
	var reward = solved_issue.threat_level * 100

	GameManager.issue_solved()
	GameManager.add_score(reward)

	has_issue = false
	current_issue = null
	patience = 100

	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false

	GameManager.incidents_changed.emit()

func escalate():
	if escalated:
		return
	var failed_issue = current_issue
	if failed_issue == null:
		return
	escalated = true
	GameManager.issue_failed()
	print(
		"INCIDENT ESCALATED:",
		failed_issue.issue_name
	)
	print(
		"Consequence:",
		failed_issue.escalation
	)
	GameManager.add_score(
		-failed_issue.threat_level * 100
	)
	has_issue = false
	current_issue = null
	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false
	GameManager.incidents_changed.emit()
