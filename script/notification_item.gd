extends PanelContainer
class_name NotificationItem

enum DisplayMode { TIMER, PERCENTAGE }

@export var display_mode: DisplayMode = DisplayMode.TIMER

@onready var notification_container: VBoxContainer = $MarginContainer/VBoxContainer

@onready var name_label: RichTextLabel = $MarginContainer/VBoxContainer/HeaderHBoxContainer/NameLabel
@onready var time_label: RichTextLabel = $MarginContainer/VBoxContainer/HeaderHBoxContainer/TimerLabel
@onready var description_label: RichTextLabel = $MarginContainer/VBoxContainer/DecriptionLabel

#var for bubble expansion
var is_expanded: bool = false
@export var collapsed_height: float = 35.0
# Stored text states
var full_text: String = ""
var preview_text: String = ""

var tracked_employee: Node = null

#Speech bubble
func setup(employee) -> void:
	tracked_employee = employee
	
	# Header name with app badge
	if name_label:
		name_label.text = "[b][color=#38BDF8]%s[/color][/b]" % employee.employee_name
		
	# Description text Logic for Elipse
	if description_label:
		var raw_msg = "Issue requires attention!"
		if employee.current_issue:
			if employee.current_issue.get("employee_message") != null and employee.current_issue.employee_message != "":
				raw_msg = employee.current_issue.employee_message
			elif employee.current_issue.get("description") != null:
				raw_msg = employee.current_issue.description
		
		# Replace newlines with single spaces
		var msg = raw_msg.replace("\r\n", " ").replace("\n", " ").replace("\r", " ")
		while "  " in msg:
			msg = msg.replace("  ", " ")
			
		full_text = "[color=#F3F4F6]%s[/color]" % msg
		
		# Set's Character limit for elipse to appear
		if msg.length() > 45:
			var raw_cutoff = msg.left(45)
			var last_space = raw_cutoff.rfind(" ")
			
			if last_space > 0:
				raw_cutoff = raw_cutoff.left(last_space)
				
			var short_msg = raw_cutoff.strip_edges(false, true)
			var styled_ellipsis = "[b][font_size=13][color=#F3F4F6]...[/color][/font_size][/b]"
			preview_text = "[color=#F3F4F6]%s[/color]%s" % [short_msg, styled_ellipsis]
		else:
			preview_text = full_text

		# Start collapsed with clean preview text
		description_label.text = preview_text
		
	_update_patience_display()

func _process(_delta: float) -> void:
	if tracked_employee == null or !is_instance_valid(tracked_employee):
		return
	if tracked_employee.current_issue == null:
		return

	_update_patience_display()
	
#Time calculations and Display
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
	#Timer Display code
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
	
	
#Speech Bubble Expansion Code
func _ready() -> void:
	if description_label:
		description_label.clip_contents = true
		description_label.fit_content = false
		description_label.custom_minimum_size.y = collapsed_height

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_expand()

func toggle_expand() -> void:
	is_expanded = !is_expanded
	
	if description_label:
		if is_expanded:
			# Expanded state: swap to full text and allow container expansion
			description_label.text = full_text
			description_label.fit_content = true
			description_label.custom_minimum_size.y = 0
		else:
			# Collapsed state: swap to truncated text with "..." and clamp height
			description_label.text = preview_text
			description_label.fit_content = false
			description_label.custom_minimum_size.y = collapsed_height
			
	# Refresh parent container layout
	queue_sort()
	if get_parent() is Control:
		get_parent().queue_sort()
		
# Returns remaining patience/time in seconds for sorting
func get_remaining_time() -> float:
	if tracked_employee and is_instance_valid(tracked_employee):
		if tracked_employee.current_issue:
			var urgency: float = tracked_employee.current_issue.urgency
			var drain_per_second: float = urgency * 10.0
			if drain_per_second > 0:
				return tracked_employee.patience / drain_per_second
			return tracked_employee.patience
	return 999999.0
		
	
