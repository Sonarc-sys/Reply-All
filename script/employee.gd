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
@export var walking_speed = 70
var direction_ofmovement = Vector2.ZERO
var timer_movement = 0.0

var has_issue = false
@onready var patience_bar = $UI/PatienceBar
var patience = 100
var current_issue:CyberIssue

var escalated = false


func _ready():
	name_label.text = employee_name
	GameManager.register_employee(self)




	#Here, we will create different employee personalities.
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
		var exclamation = $UI/Exclamation
		if exclamation.visible:
			var pulse = 1.0 + (sin(Time.get_ticks_msec() * 0.01) * 0.1)
			exclamation.scale = Vector2(pulse, pulse)
		var urgency = current_issue.urgency
		patience -= urgency * 10 * delta
		patience_bar.value = clamp(patience,0,100)
		if patience <= 0:
			escalate()

func _physics_process(delta):
	#Here, we will countdown on our created movement timer.
	timer_movement -= delta
	
	#Here, if the timer runs out, we will pick a new direction, or stay in the same place.
	if timer_movement <= 0:
		if randf() < 0.60: #Here, why 0.60? Because the NPC character will have a 60% chance to walk or not.
			var rand_angle = randf() * TAU
			direction_ofmovement = Vector2(cos(rand_angle), sin(rand_angle))
			timer_movement = randf_range(1.0, 3.0)
		else: #Here, we are saying or else the NPC will have a 40% chance to stay still.
			direction_ofmovement = Vector2.ZERO
			timer_movement = randf_range(1.5, 4.0)
	
	
	#Here, we will move the NPC safely while also at the same time, matching the physics collision engine.
	velocity = direction_ofmovement * walking_speed
	move_and_slide()


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
			
	var exclamation = $UI/Exclamation
	exclamation.visible = true
	
	#Here, we will create a pop animation.
	exclamation.scale =Vector2.ZERO
	var thetween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	thetween.tween_property(exclamation, "scale", Vector2(1,1), 0.5)
	GameManager.incidents_changed.emit()
	print(employee_name, "receieved issue: ", issue.issue_name)

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
