extends Control

@onready var list_vbox   = $IPad/Screen/Inner/Scroll/VBox
@onready var empty_label = $IPad/Screen/Inner/Scroll/VBox/EmptyLabel
@onready var title_label = $IPad/Screen/Inner/TitleBar/TitleLabel
@onready var ipad        = $IPad

func _ready():
	title_label.text = "  Reflection Report"

	# Slide in from right
	ipad.position.x = 900
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(ipad, "position:x", 0.0, 0.42)

	var has_entries = not GameManager.wrong_answers.is_empty()
	empty_label.visible = not has_entries

	for entry in GameManager.wrong_answers:
		var card = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.09, 0.09, 0.12)
		sb.border_color = Color(0.88, 0.22, 0.22, 0.6)
		sb.border_width_top = 2
		sb.border_width_left = 2
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.corner_radius_top_left = 8
		sb.corner_radius_top_right = 8
		sb.corner_radius_bottom_left = 8
		sb.corner_radius_bottom_right = 8
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		card.add_theme_stylebox_override("panel", sb)

		var vb = VBoxContainer.new()
		vb.add_theme_constant_override("separation", 6)

		var issue_lbl = Label.new()
		issue_lbl.text = entry["issue_name"]
		issue_lbl.add_theme_font_size_override("font_size", 15)
		issue_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))

		# Show the actual question/description if recorded
		var desc_lbl: Label = null
		if entry.get("description", "") != "":
			desc_lbl = Label.new()
			desc_lbl.text = entry["description"]
			desc_lbl.add_theme_font_size_override("font_size", 12)
			desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.78, 0.88))
			desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		var div = ColorRect.new()
		div.custom_minimum_size = Vector2(0, 1)
		div.color = Color(0.18, 0.20, 0.28)

		var correct_row = HBoxContainer.new()
		correct_row.add_theme_constant_override("separation", 6)
		var check = Label.new()
		check.text = "✓"
		check.add_theme_font_size_override("font_size", 14)
		check.add_theme_color_override("font_color", Color(0.18, 0.82, 0.40))
		var correct_lbl = Label.new()
		correct_lbl.text = entry["correct_answer"]
		correct_lbl.add_theme_font_size_override("font_size", 13)
		correct_lbl.add_theme_color_override("font_color", Color(0.18, 0.82, 0.40))
		correct_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		correct_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		correct_row.add_child(check)
		correct_row.add_child(correct_lbl)

		var expl = Label.new()
		expl.text = entry["explanation"]
		expl.add_theme_font_size_override("font_size", 12)
		expl.add_theme_color_override("font_color", Color(0.60, 0.63, 0.72))
		expl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		vb.add_child(issue_lbl)
		if desc_lbl: vb.add_child(desc_lbl)
		vb.add_child(div)
		vb.add_child(correct_row)
		vb.add_child(expl)
		card.add_child(vb)
		list_vbox.add_child(card)

func _on_close_pressed():
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(ipad, "position:x", 900.0, 0.32)
	tw.tween_callback(func(): get_tree().change_scene_to_file("res://scene/GameOver.tscn"))
