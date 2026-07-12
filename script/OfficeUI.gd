extends CanvasLayer

const TRIAGE_ITEM_SCENE = preload("res://scene/TriageItem.tscn")

var score_label
var incident_list

func _ready():
	score_label   = get_node("ScoreLabel")
	incident_list = get_node("TriagePanel/IncidentList")

	GameManager.score_changed.connect(update_score)
	GameManager.incidents_changed.connect(update_triage)

	update_score(GameManager.score)
	update_triage()

func update_score(score):
	if score_label:
		score_label.text = "Security Score: " + str(score)

func update_triage():
	if incident_list == null:
		print("update_triage: incident_list node not found! Check your path.")
		return

	for child in incident_list.get_children():
		child.queue_free()

	for employee in GameManager.employees:
		if not is_instance_valid(employee):
			continue
		if employee.has_issue and employee.current_issue:
			var item_instance = TRIAGE_ITEM_SCENE.instantiate()
			incident_list.add_child(item_instance)

			var item_label = item_instance.find_child("Label", true, false) as Label
			if item_label:
				item_label.text = (
					employee.employee_name
					+ " ("
					+ employee.employee_type
					+ ")\n"
					+ "⚠️ " + employee.current_issue.employee_message
					+ "\n\nPatience: "
					+ str(round(employee.patience))
					+ "%"
				)
				item_label.add_theme_color_override("font_color", Color.WHITE)
