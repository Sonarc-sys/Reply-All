extends CanvasLayer

@export var notification_scene: PackedScene = preload("res://scene/NotificationItem.tscn")

var score_label: Label
@onready var notification_list: VBoxContainer = $Phone/ScrollContainer/NotificationList

# Keep track of active notifications tied to employees
var active_notifications: Dictionary = {}

func _ready() -> void:
	
	score_label = get_node_or_null("ScoreLabel")

	# Connect signals
	GameManager.score_changed.connect(update_score)
	GameManager.incidents_changed.connect(update_triage)

	# Run initial updates
	update_score(GameManager.score)
	update_triage()

func update_score(score: int) -> void:
	if score_label:
		score_label.text = "Security Score: " + str(score)

func update_triage() -> void:
	
	for employee in GameManager.employees:
		
		# Spawning new notifications
		if employee.has_issue and employee.current_issue != null:
			if !active_notifications.has(employee):
				var item = notification_scene.instantiate()
				notification_list.add_child(item)
				item.setup(employee)
				active_notifications[employee] = item

	# Removing notifications for fixed/failed issues
	var employees_to_remove = []
	for employee in active_notifications.keys():
		if !employee.has_issue or employee.current_issue == null:
			var item = active_notifications[employee]
			item.queue_free()
			employees_to_remove.append(employee)

	for emp in employees_to_remove:
		active_notifications.erase(emp)
