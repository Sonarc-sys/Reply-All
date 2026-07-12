extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var incident_list = $TriagePanel/IncidentList

# Preload your newly styled cell notification / clipboard item template
const TRIAGE_ITEM_SCENE = preload("res://scene/TriageItem.tscn")

func _ready():
	GameManager.score_changed.connect(update_score)
	GameManager.incidents_changed.connect(update_triage)

	update_score(GameManager.score)
	update_triage()

func update_score(score):
	score_label.text = "Security Score: " + str(score)

func update_triage():
	# Clean up old entries safely
	for child in incident_list.get_children():
		child.queue_free()

	# Rebuild the queue with styled elements
	for employee in GameManager.employees:
		if employee.has_issue and employee.current_issue:
			# Instantiate your custom clipboard/cellphone box layout
			var item_instance = TRIAGE_ITEM_SCENE.instantiate()
			incident_list.add_child(item_instance)
			
			# Find the label inside your template node structure to assign the text safely
			# (Adjust the path below if your label is nested differently)
			var item_label = item_instance.get_node("MarginContainer/Label") as Label
			
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
				# Give it a high-contrast text color depending on your theme style background
				item_label.add_theme_color_override("font_color", Color.WHITE)
