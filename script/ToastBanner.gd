extends PanelContainer

@onready var rich_label: RichTextLabel = $MarginContainer/RichTextLabel

# Style settings 
@export var name_color: String = "#38BDF8"  # Cool Sky Blue 
@export var text_color: String = "#F3F4F6"  # Soft Off-White
@export var app_tag_color: String = "#9CA3AF" # Muted Gray for header tag

var current_tween: Tween = null

func _ready() -> void:
	visible = false

func show_toast(employee_name: String, employee_message: String) -> void:
	if rich_label == null:
		return

	# Format text 
	# Example output: [SMS] Alex: Needs password reset
	var formatted_text = "[color=%s][b]💬 NOTIFICATION[/b][/color]\n" % app_tag_color
	formatted_text += "[color=%s][b]%s:[/b][/color] [color=%s]%s[/color]" % [
		name_color, 
		employee_name, 
		text_color, 
		employee_message
	]

	rich_label.text = formatted_text

	# Interrupt running animation if a new notification fires quickly
	if current_tween and current_tween.is_running():
		current_tween.kill()

	visible = true
	modulate.a = 0.0

	# Fade Animation
	current_tween = create_tween().set_parallel(true)
	current_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	var seq = create_tween()
	seq.tween_interval(3.0) # Time visible on screen
	seq.tween_property(self, "modulate:a", 0.0, 0.4)
	seq.tween_callback(func(): visible = false)
