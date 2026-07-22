extends Node

var time_left = 60
var day_over = false

var score = 0
signal incidents_changed
signal score_changed
var incidents_handled = 0
var incidents_failed = 0

var employees = []
var unsucessful_job_hist: Array = []



var issues = [
	preload("res://resources/Issue Resources/PhishingEmail.tres"),
	preload("res://resources/Issue Resources/SuspiciousUSB.tres"),
	preload("res://resources/Issue Resources/ForgotPassword.tres")
]
var high_threat_issues = []
var normal_issues = []



func _ready():
	# Here, we will create code that will separate issues by their  threat.
	for issue in issues:
		if issue.threat_level >= 4:
			high_threat_issues.append(issue)
		else:
			normal_issues.append(issue)
	print("High threat issues:", high_threat_issues.size())
	print("Normal issues:", normal_issues.size())

func register_employee(employee):
	if !employees.has(employee):
		employees.append(employee)
		
func _process(delta):
	if day_over:
		return
	time_left -= delta
	if time_left <= 0:
		end_day()
		
func spawn_issue():
	var chance = randf()
	#Here, we say that there is a 25% chance of serious incident.
	if chance < 0.25:
		spawn_high_threat()
	else:
		spawn_normal_issue()

func spawn_high_threat():
	if high_threat_issues.is_empty():
		return
	var employee = get_available_employee()
	if employee == null:
		return
	var issue = high_threat_issues.pick_random()
	employee.create_issue(issue)
	incidents_changed.emit()

func spawn_normal_issue():
	if normal_issues.is_empty():
		return
	var employee = get_available_employee()
	if employee == null:
		return
	var issue = normal_issues.pick_random()
	employee.create_issue(issue)
	incidents_changed.emit()

func get_available_employee():
	var available = []
	for employee in employees:
		if !employee.has_issue:
			available.append(employee)
	if available.is_empty():
		return null
	return available.pick_random()


func issue_solved():
	incidents_handled += 1
	incidents_changed.emit()


func issue_failed():
	incidents_failed += 1
	incidents_changed.emit()

func add_score(amount):
	score += amount
	score_changed.emit(score)
	
	
func end_day():
	day_over = true
	print("SHIFT COMPLETE")
	print(
		"Incidents handled: ",
		incidents_handled
	)
	print(
		"Incidents failed: ",
		incidents_failed
	)
	print(
		"Final score: ",
		score
	)
	get_tree().change_scene_to_file("res://scene/GameOver.tscn")
	
func write_failure(issue: CyberIssue):
	unsucessful_job_hist.append({
		"issue_name": issue.issue_name,
		"description": issue.description,
		"right_answer": issue.answers[issue.correct_index],
		"explanation": issue.explanation
	})
