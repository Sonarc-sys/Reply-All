extends CanvasLayer

@export var notification_scene: PackedScene = preload("res://scene/NotificationItem.tscn")

var score_label: RichTextLabel
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
	var lbl: RichTextLabel = get_node_or_null("TopHUD/TimerCard/MarginContainer/TimerLabel")
	if lbl == null: return
	var t = max(0.0, GameManager.time_left)
	var mins = int(t) / 60
	var secs = int(t) % 60
	var time_str = "%d:%02d" % [mins, secs]
	# Emergency panic color shift
	if t < 15.0:
		lbl.text = "[center]⏱ [color=#F43F5E][b]%s[/b][/color][/center]" % time_str
	else:
		lbl.text = "[center]⏱ [color=#F3F4F6]%s[/color][/center]" % time_str

func _update_danger(value: float):
	var bar = get_node_or_null("DangerRow/DangerBar")
	var lbl: RichTextLabel = get_node_or_null("DangerRow/DangerLabel")
	# Color thresholds (In Hext)
	var hex_color = "#34D399" # Soft Green (Low threat)
	if value > 60.0: 
		hex_color = "#FBBF24" # Warning Orange/Yellow
	if value > 80.0: 
		hex_color = "#F43F5E" # Emergency Red
	# Update Progress Bar Tint
	if bar:
		bar.value = value
		bar.modulate = Color(hex_color)
	# Update Text
	if lbl:
		#lbl.text = "⚠️ [color=%s][b]THREAT:[/b] %.0f%%[/color]" % [hex_color, value]
		lbl.text = "[outline_size=5][outline_color=#000000]⚠️ [color=%s][b]THREAT:[/b] %.0f%%[/color][/outline_color][/outline_size]" % [hex_color, value]

func update_score(score: int) -> void:
	if score_label == null:
		score_label = get_node_or_null("TopHUD/ScoreCard/MarginContainer/ScoreLabel")
			
	if score_label is RichTextLabel:
		score_label.text = "[center]🛡️ [color=#38BDF8][b]SCORE:[/b][/color] [color=#F3F4F6]%d[/color][/center]" % score

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
