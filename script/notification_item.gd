extends PanelContainer
class_name NotificationItem

enum DisplayMode { TIMER, PERCENTAGE }

# Change this to DisplayMode.PERCENTAGE if you prefer percentages!
@export var display_mode: DisplayMode = DisplayMode.TIMER

@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/NameLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/TimeLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/PanelContainer/Control/DescriptionLabel

var tracked_employee: Node = null
var marquee_speed: float = 30.0

func setup(employee) -> void:
	tracked_employee = employee
	name_label.text = employee.employee_name
	description_label.text = employee.current_issue.description
	_update_patience_display()

func _process(delta: float) -> void:
	# 1. Guard check: Make sure employee exists AND still has a valid current issue
	if tracked_employee == null or !is_instance_valid(tracked_employee):
		return
	if tracked_employee.current_issue == null:
		return

	_update_patience_display()

	# --- MARQUEE LOGIC ---
	var parent_container = description_label.get_parent() as Control
	if parent_container:
		var window_width = parent_container.size.x
		var text_width = description_label.get_minimum_size().x

		if text_width > window_width:
			description_label.position.x -= marquee_speed * delta
			if description_label.position.x < -text_width:
				description_label.position.x = window_width
		else:
			description_label.position.x = 0


func _update_patience_display() -> void:
	# 2. Extra safety check inside the update function
	if tracked_employee == null or tracked_employee.current_issue == null:
		return

	var urgency: float = tracked_employee.current_issue.urgency
	var drain_per_second: float = urgency * 10.0
	
	var remaining_seconds: float = 0.0
	if drain_per_second > 0:
		remaining_seconds = tracked_employee.patience / drain_per_second

	match display_mode:
		DisplayMode.TIMER:
			time_label.text = _format_time(remaining_seconds)
			if remaining_seconds <= 10.0:
				time_label.modulate = Color.RED
			else:
				time_label.modulate = Color.WHITE

		DisplayMode.PERCENTAGE:
			var percent: int = int(round(tracked_employee.patience))
			time_label.text = str(percent) + "%"

func _format_time(total_seconds: float) -> String:
	var secs: int = int(ceil(max(0, total_seconds)))
	var minutes: int = secs / 60
	var remaining_secs: int = secs % 60
	
	# Formats as "01:05" or "00:42"
	return "%02d:%02d" % [minutes, remaining_secs]
