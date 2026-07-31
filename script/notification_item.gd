extends PanelContainer
class_name NotificationItem

enum DisplayMode { TIMER, PERCENTAGE }

@export var display_mode: DisplayMode = DisplayMode.TIMER

@onready var name_label: RichTextLabel = $MarginContainer/VBoxContainer/HeaderHBoxContainer/NameLabel
@onready var time_label: RichTextLabel = $MarginContainer/VBoxContainer/HeaderHBoxContainer/TimerLabel
@onready var description_label: RichTextLabel = $MarginContainer/VBoxContainer/DecriptionLabel

var tracked_employee: Node = null

func setup(employee) -> void:
	tracked_employee = employee
	
	# Header name with bold styling and subtle app badge
	if name_label:
		name_label.text = "[b][color=#38BDF8]%s[/color][/b]" % employee.employee_name
		
	# Description text with subtle muted grey/blue color
	if description_label:
		var msg = employee.current_issue.employee_message if employee.current_issue.get("employee_message") else employee.current_issue.description
		description_label.text = "[color=#F3F4F6]%s[/color]" % msg
		
	_update_patience_display()

func _process(_delta: float) -> void:
	if tracked_employee == null or !is_instance_valid(tracked_employee):
		return
	if tracked_employee.current_issue == null:
		return

	_update_patience_display()

func _update_patience_display() -> void:
	if tracked_employee == null or tracked_employee.current_issue == null:
		return

	# Calculating timer directly based on patience
	var urgency: float = tracked_employee.current_issue.urgency
	var drain_per_second: float = urgency * 10.0
	
	var remaining_seconds: float = 0.0
	if drain_per_second > 0:
		remaining_seconds = tracked_employee.patience / drain_per_second

	if time_label == null:
		return

	match display_mode:
		DisplayMode.TIMER:
			var formatted = _format_time(remaining_seconds)
			if remaining_seconds <= 10.0:
				time_label.text = "[right][color=#F43F5E]⏱ %s[/color][/right]" % formatted
			else:
				time_label.text = "[right][color=#64748B]⏱ %s[/color][/right]" % formatted

		DisplayMode.PERCENTAGE:
			var percent: int = int(round(tracked_employee.patience))
			if percent <= 25:
				time_label.text = "[right][color=#F43F5E]%d%%[/color][/right]" % percent
			else:
				time_label.text = "[right][color=#64748B]%d%%[/color][/right]" % percent

func _format_time(total_seconds: float) -> String:
	var secs: int = int(ceil(max(0, total_seconds)))
	var minutes: int = secs / 60
	var remaining_secs: int = secs % 60
	return "%02d:%02d" % [minutes, remaining_secs]
