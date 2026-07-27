extends Control

@onready var label = $CenterContainer/VBox/LineLabel

var _all_lines: Array = []
var line_index  = 0
var char_index  = 0
var full_text   = ""
var typing      = false
var line_timer  = 0.0
var _done       = false

const CHAR_DELAY = 0.045
const LINE_PAUSE = 1.0

func _ready():
	# Start fully black then fade in
	modulate = Color(0, 0, 0, 1)
	var fade_in = create_tween()
	fade_in.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.8)

	var handled = GameManager.incidents_handled
	var failed  = GameManager.incidents_failed
	var danger  = GameManager.danger

	var closing = []
	if danger >= 100.0:
		closing = [
			"The company is compromised.",
			"Attackers are in the building... metaphorically.",
			"",
			"You had ONE job.",
		]
	elif failed == 0:
		closing = [
			"Zero failures.",
			"The CEO said your name correctly for once.",
			"",
			"Enjoy it. It won't last.",
		]
	elif failed > handled:
		closing = [
			"Meh.",
			"You could do better.",
			"",
			"Maybe try turning yourself off and on again.",
		]
	else:
		closing = [
			"Not bad.",
			"Not great either.",
			"",
			"But the printers still work, so... progress?",
		]

	_all_lines = ["Shift complete.", ""] + closing + ["", "Loading results..."]
	label.text = ""
	_start_line()

func _start_line():
	if line_index >= _all_lines.size():
		if not _done:
			_done = true
			# Use a tween delay instead of await to avoid signal issues
			var tw = create_tween()
			tw.tween_interval(1.0)
			tw.tween_callback(_go_to_gameover)
		return
	full_text  = _all_lines[line_index]
	char_index = 0
	label.text = ""
	typing     = true
	line_timer = 0.0

func _go_to_gameover():
	get_tree().change_scene_to_file("res://scene/GameOver.tscn")

func _process(delta):
	if _done:
		return
	if not typing:
		line_timer -= delta
		if line_timer <= 0.0:
			line_index += 1
			_start_line()
		return
	line_timer += delta
	if line_timer >= CHAR_DELAY:
		line_timer = 0.0
		if char_index < full_text.length():
			char_index += 1
			label.text = full_text.substr(0, char_index)
		else:
			typing     = false
			line_timer = LINE_PAUSE

func _input(event):
	if _done:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_done = true
		_go_to_gameover()
