extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var incident_list = $TriagePanel/IncidentList


func _ready():
	GameManager.score_changed.connect(update_score)
	GameManager.incidents_changed.connect(update_triage)

	update_score(GameManager.score)
	update_triage()

func update_score(score):
	score_label.text = (
		"Security Score: "
		+ str(score)
	)



func update_triage():
	# remove old entries
	for child in incident_list.get_children():
		child.queue_free()

	for employee in GameManager.employees:
		if employee.has_issue:
			var label = Label.new()
			label.text = (
				employee.employee_name
				+ " (" 
				+ employee.employee_type
				+ ")\n\n"
				+ employee.current_issue.employee_message
				+ "\n\nPatience: "
				+ str(round(employee.patience))
				+ "%"
			)
			label.add_theme_color_override(
				"font_color",
				Color.BLACK
)
			incident_list.add_child(label)
			
func _process(delta):
	update_triage()
