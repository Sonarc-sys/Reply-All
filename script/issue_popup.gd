extends Control

var current_employee = null
var current_issue: CyberIssue = null
var correct_button: int = 0

@onready var employee_label : Label  = $Tablet/Screen/Inner/Header/HeaderContent/HeaderText/EmployeeLabel
@onready var role_label     : Label  = $Tablet/Screen/Inner/Header/HeaderContent/HeaderText/RoleLabel
@onready var message_label  : Label  = $Tablet/Screen/Inner/ScrollArea/Body/MsgSection/MsgPad/MessageLabel
@onready var feedback_pad            = $Tablet/Screen/Inner/ScrollArea/Body/FeedbackPad
@onready var feedback_label : Label  = $Tablet/Screen/Inner/ScrollArea/Body/FeedbackPad/FeedbackLabel
@onready var btn1           : Button = $Tablet/Screen/Inner/ScrollArea/Body/ResponseSection/Choices/Option1
@onready var btn2           : Button = $Tablet/Screen/Inner/ScrollArea/Body/ResponseSection/Choices/Option2
@onready var btn3           : Button = $Tablet/Screen/Inner/ScrollArea/Body/ResponseSection/Choices/Option3
@onready var close_btn      : Button = $Tablet/Screen/Inner/Footer/CloseBtn
@onready var accent_line    : ColorRect = $Tablet/Screen/Inner/AccentLine
@onready var tablet                  = $Tablet

func _ready():
	_style_buttons()

func _style_buttons():
	for btn in [btn1, btn2, btn3]:
		var sb_n := StyleBoxFlat.new()
		sb_n.bg_color = Color(0.10, 0.10, 0.14)
		sb_n.border_color = Color(0.22, 0.24, 0.32)
		sb_n.border_width_left=1; sb_n.border_width_right=1
		sb_n.border_width_top=1;  sb_n.border_width_bottom=1
		sb_n.corner_radius_top_left=8; sb_n.corner_radius_top_right=8
		sb_n.corner_radius_bottom_left=8; sb_n.corner_radius_bottom_right=8
		sb_n.content_margin_left=12; sb_n.content_margin_right=12
		sb_n.content_margin_top=6; sb_n.content_margin_bottom=6
		btn.add_theme_stylebox_override("normal", sb_n)
		# Hover  -  subtle blue only, no green/red
		var sb_h := sb_n.duplicate()
		sb_h.bg_color    = Color(0.08, 0.15, 0.28)
		sb_h.border_color = Color(0.30, 0.45, 0.75)
		btn.add_theme_stylebox_override("hover",   sb_h)
		var sb_p := sb_n.duplicate()
		sb_p.bg_color    = Color(0.06, 0.12, 0.22)
		sb_p.border_color = Color(0.22, 0.35, 0.60)
		btn.add_theme_stylebox_override("pressed", sb_p)
		# Disabled  -  same as normal, no colour change
		btn.add_theme_stylebox_override("disabled", sb_n)
		btn.add_theme_color_override("font_color",          Color(0.82, 0.84, 0.92))
		btn.add_theme_color_override("font_hover_color",    Color(0.95, 0.96, 1.00))
		btn.add_theme_color_override("font_pressed_color",  Color(0.80, 0.84, 0.92))
		btn.add_theme_color_override("font_disabled_color", Color(0.82, 0.84, 0.92))

func open(employee) -> void:
	if employee == null or employee.current_issue == null:
		return
	current_employee = employee
	current_issue    = employee.current_issue
	# NOTE: NO pausing  -  timer keeps running

	employee_label.text = employee.employee_name
	role_label.text     = employee.employee_type.replace("_", " ")
	message_label.text  = current_issue.employee_message

	feedback_pad.visible = false
	close_btn.visible    = false
	close_btn.text       = "Close Ticket"
	accent_line.color    = Color(0.0, 0.48, 1.0)

	var answers = current_issue.answers.duplicate()
	var correct  = answers[current_issue.correct_index]
	answers.shuffle()
	btn1.text = answers[0]; btn2.text = answers[1]; btn3.text = answers[2]
	correct_button = answers.find(correct)
	_set_buttons_disabled(false)
	_reset_button_styles()

	visible = true
	tablet.position.y = 700
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(tablet, "position:y", 0.0, 0.38)

	if has_node("/root/AudioManager"):
		var sfx = load("res://audio/sfx_popup.wav")
		if sfx: get_node("/root/AudioManager").play_sfx(sfx)

func _set_buttons_disabled(v: bool):
	btn1.disabled = v; btn2.disabled = v; btn3.disabled = v

func _reset_button_styles():
	_style_buttons()

func _on_option_1_pressed(): _check_answer(0)
func _on_option_2_pressed(): _check_answer(1)
func _on_option_3_pressed(): _check_answer(2)

func _check_answer(idx: int):
	_set_buttons_disabled(true)
	if idx == correct_button: _correct(idx)
	else:                     _wrong(idx)

func _correct(_idx: int):
	# No colour change on buttons  -  neutral
	feedback_label.text = "✓  Correct. Good call.\n" + current_issue.explanation
	feedback_label.add_theme_color_override("font_color", Color(0.82, 0.84, 0.92))
	feedback_pad.visible = true
	close_btn.text       = "Close Ticket"
	close_btn.visible    = true
	accent_line.color    = Color(0.0, 0.48, 1.0)
	current_employee.solve()
	if has_node("/root/AudioManager"):
		var sfx = load("res://audio/sfx_correct.wav")
		if sfx: get_node("/root/AudioManager").play_sfx(sfx)

func _wrong(_idx: int):
	feedback_label.text = "Incorrect.\n" + current_issue.explanation
	feedback_label.add_theme_color_override("font_color", Color(0.82, 0.84, 0.92))
	feedback_pad.visible = true
	close_btn.text       = "Close Ticket"
	close_btn.visible    = true
	accent_line.color    = Color(0.0, 0.48, 1.0)

	var the_issue = current_issue
	if the_issue == null:
		return

	# Score and danger
	GameManager.add_score(-50)

	# CRITICAL: trigger lockdown directly from popup - no intermediary
	if the_issue.threat_level == 5:
		GameManager.add_danger(30.0)
		# Clear the source NPC's issue so it can be cleared in lockdown like everyone else
		if current_employee != null:
			current_employee.has_issue    = false
			current_employee.current_issue = null
			current_employee.escalated     = false
		GameManager.trigger_lockdown()
	else:
		GameManager.add_danger(the_issue.threat_level * 4.0)
		if current_employee != null:
			current_employee.wrong_answer()

	GameManager.record_wrong_answer(the_issue.issue_name,
		the_issue.answers[the_issue.correct_index],
		the_issue.explanation)

	if has_node("/root/AudioManager"):
		var sfx = load("res://audio/sfx_wrong.wav")
		if sfx: get_node("/root/AudioManager").play_sfx(sfx)

func _on_close_pressed():
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(tablet, "position:y", 700.0, 0.28)
	tw.tween_callback(func():
		visible = false
		current_employee = null
		current_issue    = null
		accent_line.color = Color(0.0, 0.48, 1.0)
	)
