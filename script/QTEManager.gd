extends Node

enum QTEType {NONE, RANSOMWARE, EMAIL_WORMS, CEO_SPOOF}

@onready var qte_timer: Timer = Timer.new()
var qte_current: QTEType = QTEType.NONE

var employees_to_save: int = 0
var employees_saved: int = 0

func _ready() -> void:
	add_child(qte_timer)
	qte_timer.one_shot = true
	qte_timer.timeout.connect(_on_qte_failed)

func qte_trigger(escalation_path: String) -> void:
	if "Escalation_Ransomware" in escalation_path:
		qte_start(QTEType.RANSOMWARE, 12.0)
	elif "Escalation_WormBreakout" in escalation_path:
		qte_start(QTEType.EMAIL_WORMS, 10.0)
	elif "CEOFinancialFraud" in escalation_path:
		qte_start(QTEType.CEO_SPOOF, 15.0)
	else:
		return
	
	GameManager.issue_timer.set_paused(true)

func qte_start(type: QTEType, time_limit: float) -> void:
	qte_current = type
	employees_saved = 0
	employees_to_save = 0
	
	# Indentation is fixed here!
	var employees_all = get_tree().get_nodes_in_group("employees")
	for emp in employees_all:
		if type == QTEType.CEO_SPOOF and emp.role == emp.Role.CEO:
			continue
		emp.enable_qte_state(type)
		employees_to_save += 1
	
	if employees_to_save == 0:
		qte_end(true)
		return
	
	print("The QTE has started! The Time limit is: ", time_limit)
	qte_timer.start(time_limit)

func register_employee_saved() -> void:
	employees_saved += 1
	if employees_saved >= employees_to_save:
		qte_end(true)

func _on_qte_failed() -> void:
	qte_end(false)

func qte_end(success: bool) -> void:
	qte_timer.stop()
	qte_current = QTEType.NONE
	
	var employees_all = get_tree().get_nodes_in_group("employees")
	for emp in employees_all:
		emp.disable_qte_state()
	
	if success:
		print("Congratulations! The Crisis has been averted. We are returning back to the regularly scheduled gameplay now!")
		GameManager.issue_timer.set_paused(false)
	else:
		print("The QTE has not succeeded! Good job, the company Network is now compromised. Game over!")
		get_tree().change_scene_to_file("res://scene/GameOver.tscn")
