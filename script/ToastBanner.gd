extends PanelContainer

@onready var label: Label = $MarginContainer/Label

var current_tween: Tween = null

func _ready() -> void:
	visible = false

func show_toast(message: String) -> void:
	if label:
		label.text = message

	# helps with quick updates
	if current_tween and current_tween.is_running():
		current_tween.kill()

	visible = true
	modulate.a = 0.0

	# Fade logic
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 1.0, 0.25)
	current_tween.tween_interval(1)
	current_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	current_tween.tween_callback(func(): visible = false)
