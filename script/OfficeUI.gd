extends CanvasLayer

@onready var score_label = $Label
@onready var incident_list = $NinePatchRect/MarginContainer/ScrollContainer/VBoxContainer

const TRIAGE_ITEM_SCENE = preload("res://scene/TriageItem.tscn")

func _ready():
	GameManager.score_changed.connect(update_score)
	GameManager.incidents_changed.connect(update_triage)
	
	update_score(GameManager.score)
	update_triage()

func update_score(score):
	if score_label:
		score_label.text = "Security Score: " + str(score)

func update_triage():
	if not incident_list:
		push_error("incident_list node not found! Check your path.")
		return

	# Clean up old entries
	for child in incident_list.get_children():
		child.queue_free()

	# Rebuild queue
	for employee in GameManager.employees:
		if employee.has_issue and employee.current_issue:
			var item_instance = TRIAGE_ITEM_SCENE.instantiate()
			incident_list.add_child(item_instance)
