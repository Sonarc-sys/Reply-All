extends CanvasLayer

@export var notification_scene: PackedScene = preload("res://scene/NotificationItem.tscn")

var score_label: Label
@onready var notification_list: VBoxContainer = $Phone/ScrollContainer/NotificationList

@onready var toast_banner: PanelContainer = $ToastBanner

# Keep track of active notifications tied to employees
var active_notifications: Dictionary = {}

func _ready() -> void:
	score_label = get_node_or_null("ScoreLabel")

	GameManager.score_changed.connect(update_score)
	GameManager.incidents_changed.connect(update_triage)
	if GameManager.has_signal("danger_changed"):
		GameManager.danger_changed.connect(_update_danger)

	update_score(GameManager.score)
	update_triage()
	_update_danger(0.0)

func _process(_delta):
	_update_timer()

func _update_timer():
	var lbl = get_node_or_null("TimerLabel")
	if lbl == null: return
	var t = max(0.0, GameManager.time_left)
	var mins = int(t) / 60
	var secs = int(t) % 60
	lbl.text = "%d:%02d" % [mins, secs]
	lbl.modulate = Color(0.9, 0.2, 0.2) if t < 15.0 else Color.WHITE

func _update_danger(value: float):
	var bar = get_node_or_null("DangerRow/DangerBar")
	var lbl = get_node_or_null("DangerRow/DangerLabel")
	if bar:
		bar.value = value
		var col = Color(0.2, 0.9, 0.3)
		if value > 60: col = Color(1.0, 0.55, 0.0)
		if value > 80: col = Color(0.9, 0.2, 0.2)
		bar.modulate = col
	if lbl:
		lbl.text = "Threat: %.0f%%" % value
		var col2 = Color(0.2, 0.9, 0.3)
		if value > 60: col2 = Color(1.0, 0.55, 0.0)
		if value > 80: col2 = Color(0.9, 0.2, 0.2)
		lbl.add_theme_color_override("font_color", col2)

func update_score(score: int) -> void:
	if score_label:
		score_label.text = "Security Score: " + str(score)

func update_triage() -> void:
	
	for employee in GameManager.employees:
		
		# Spawning new Phone notifications
		if employee.has_issue and employee.current_issue != null:
			if !active_notifications.has(employee):
				var item = notification_scene.instantiate()
				notification_list.add_child(item)
				item.setup(employee)
				active_notifications[employee] = item
		#Spawn toaster notification
				if toast_banner and toast_banner.has_method("show_toast"):
					toast_banner.show_toast(
					employee.employee_name, 
					employee.current_issue.employee_message
					)
				

	# Removing notifications for fixed/failed issues
	var employees_to_remove = []
	for employee in active_notifications.keys():
		if !employee.has_issue or employee.current_issue == null:
			var item = active_notifications[employee]
			item.queue_free()
			employees_to_remove.append(employee)

	for emp in employees_to_remove:
		active_notifications.erase(emp)
